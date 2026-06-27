import QtQuick
import QtQml
import Quickshell.Bluetooth
import Quickshell.Io
import "../components/themeengine"

Item {
id: bluetoothModule

required property var globalMenu
required property var parentWindow

readonly property color disabledColor: ColorRegistry.bluetoothDisabledColor
readonly property color disconnectedColor: ColorRegistry.bluetoothDisconnectedColor
readonly property color connectedColor: ColorRegistry.bluetoothConnectedColor
readonly property color labelColor: ColorRegistry.bluetoothLabelColor
readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
readonly property int labelFontSize: TypographyRegistry.appliedFontSize

readonly property var adapter: Bluetooth.defaultAdapter
readonly property var devicesModel: Bluetooth.devices
readonly property bool isBluetoothOn: adapter ? adapter.enabled : false

implicitWidth: bluetoothRow.implicitWidth
implicitHeight: bluetoothModule.parentWindow ? bluetoothModule.parentWindow.barHeight : 30

property var currentMenuDevice: null
property string pendingDeviceAddress: ""
property string pendingDeviceState: ""
property var ignoredDevices: []
property var deviceToConnectPostPair: null

property bool isPairingProcess: false
property bool isReady: false
property var lastStates: ({})

Component.onCompleted: {
const list = bluetoothModule.devicesModel ? bluetoothModule.devicesModel.values : [];
let initStates = {};
for (let i = 0; i < list.length; i++) {
let d = list[i];
if (d) {
initStates[d.address] = { connected: d.connected, paired: (d.paired || d.bonded) };
}
}
bluetoothModule.lastStates = initStates;
Qt.callLater(() => { bluetoothModule.isReady = true; });
}

Process { id: notifyProcess }

function sendNotification(title, message, urgency) {
notifyProcess.exec(["notify-send", "-u", urgency, title, message]);
}

Instantiator {
model: bluetoothModule.devicesModel ? bluetoothModule.devicesModel.values : []
delegate: Connections {
target: modelData

function onConnectedChanged() {
if (!bluetoothModule.isReady) return;

let addr = target.address;
let isConnected = target.connected;
let oldState = bluetoothModule.lastStates[addr];

if (!oldState) {
bluetoothModule.lastStates[addr] = { connected: isConnected, paired: target.paired || target.bonded };
return;
}

if (oldState.connected === isConnected) return;

oldState.connected = isConnected;

if (bluetoothModule.isPairingProcess && bluetoothModule.pendingDeviceAddress === addr) return;
if (!isConnected && bluetoothModule.deviceToConnectPostPair && bluetoothModule.deviceToConnectPostPair.address === addr) return;

let devName = target.name || addr;
bluetoothModule.sendNotification("Bluetooth", (isConnected ? "Conectado: " : "Desconectado: ") + devName, "low");

Qt.callLater(() => bluetoothModule.updateMenu(false));
}

function onPairedChanged() {
if (!bluetoothModule.isReady) return;
updateDeviceStateCache(target);
}

function onBondedChanged() {
if (!bluetoothModule.isReady) return;
updateDeviceStateCache(target);
}

function updateDeviceStateCache(devTarget) {
let addr = devTarget.address;
if (bluetoothModule.lastStates[addr]) {
bluetoothModule.lastStates[addr].paired = devTarget.paired || devTarget.bonded;
} else {
bluetoothModule.lastStates[addr] = { connected: devTarget.connected, paired: devTarget.paired || devTarget.bonded };
}
Qt.callLater(() => bluetoothModule.updateMenu(false));
}
}
}

Connections {
target: bluetoothModule.adapter ? bluetoothModule.adapter : null
function onEnabledChanged() {
bluetoothModule.updateMenu(false);
if (!bluetoothModule.isBluetoothOn) {
bluetoothModule.lastStates = {};
}
}
function onDiscoveringChanged() {
if (bluetoothModule.adapter && bluetoothModule.adapter.discovering) {
discoveryTimeoutTimer.restart();
} else {
discoveryTimeoutTimer.stop();
}
bluetoothModule.updateMenu(false);
}
}

Timer {
id: discoveryTimeoutTimer
interval: 60000
repeat: false
onTriggered: {
if (bluetoothModule.adapter && bluetoothModule.adapter.discovering) {
bluetoothModule.adapter.discovering = false;
}
}
}

Timer {
id: discoveryRefreshTimer
interval: 5000
repeat: true
running: bluetoothModule.adapter && bluetoothModule.adapter.discovering && bluetoothModule.globalMenu && bluetoothModule.globalMenu.visible && bluetoothModule.currentMenuDevice === null
onTriggered: {
bluetoothModule.updateMenu(true);
}
}

Timer {
id: connectionDelayTimer
interval: 5000
repeat: false
onTriggered: {
if (bluetoothModule.deviceToConnectPostPair) {
bluetoothModule.pendingDeviceAddress = bluetoothModule.deviceToConnectPostPair.address;
bluetoothModule.pendingDeviceState = "connecting";
bluetoothModule.deviceToConnectPostPair.connect();

bluetoothModule.deviceToConnectPostPair = null;
bluetoothModule.isPairingProcess = false;
bluetoothModule.currentMenuDevice = null;

bluetoothModule.updateMenu(true);
}
}
}

function getConnectedDevice() {
const list = devicesModel?.values ?? [];
for (let i = 0; i < list.length; ++i) {
const dev = list[i];
if (dev?.connected && bluetoothModule.ignoredDevices.indexOf(dev.address) === -1)
return dev;
}
return null;
}

function generateMainMenu() {
let menuModel = [];
if (!isBluetoothOn) {
menuModel.push({ text: "Ligar Bluetooth", onTrigger: () => { if (adapter) adapter.enabled = true; } });
return menuModel;
}

menuModel.push({ text: "Desligar Bluetooth", onTrigger: () => { if (adapter) adapter.enabled = false; } });
menuModel.push({
text: adapter && adapter.discovering ? "Parar Busca" : "Iniciar Busca",
preventClose: true,
onTrigger: () => { if (adapter) adapter.discovering = !adapter.discovering; }
});

const list = devicesModel?.values ?? [];
let pairedDevices = [];
let newDevices = [];

for (let i = 0; i < list.length; i++) {
let mainDev = list[i];
if (!mainDev || bluetoothModule.ignoredDevices.indexOf(mainDev.address) !== -1) continue;

if (mainDev.bonded || mainDev.paired) {
pairedDevices.push(mainDev);
} else if (adapter && adapter.discovering) {
newDevices.push(mainDev);
}
}

if (pairedDevices.length > 0) {
menuModel.push({ type: "separator" });
for (let j = 0; j < pairedDevices.length; j++) {
let pDev = pairedDevices[j];
let label = (pDev.connected ? "! " : "? ") + (pDev.name || pDev.address);
if (pDev.connected && pDev.batteryAvailable) {
label += ` (${Math.round(pDev.battery * 100)}%)`;
}
menuModel.push({
text: label,
preventClose: true,
onTrigger: () => { openDeviceSubMenu(pDev); }
});
}
}

if (newDevices.length > 0) {
menuModel.push({ type: "separator" });
for (let k = 0; k < newDevices.length; k++) {
let nDev = newDevices[k];
menuModel.push({
text: "? " + (nDev.name || nDev.address),
preventClose: true,
onTrigger: () => { openDeviceSubMenu(nDev); }
});
}
}

return menuModel;
}

function generateDeviceMenu(dev) {
let menuModel = [];
if (!dev) return menuModel;

let isConnecting = (bluetoothModule.pendingDeviceAddress === dev.address && bluetoothModule.pendingDeviceState === "connecting");
let isDisconnecting = (bluetoothModule.pendingDeviceAddress === dev.address && bluetoothModule.pendingDeviceState === "disconnecting");
let isPairing = (bluetoothModule.pendingDeviceAddress === dev.address && bluetoothModule.pendingDeviceState === "pairing");
let isWaitingConnect = (bluetoothModule.deviceToConnectPostPair && bluetoothModule.deviceToConnectPostPair.address === dev.address);

if (isPairing && (dev.paired || dev.bonded)) {
if (!dev.trusted) dev.trusted = true;

bluetoothModule.pendingDeviceAddress = "";
bluetoothModule.pendingDeviceState = "";
isPairing = false;

if (adapter) adapter.discovering = false;

bluetoothModule.deviceToConnectPostPair = dev;
connectionDelayTimer.restart();
isWaitingConnect = true;
}

if (isConnecting && dev.connected) {
bluetoothModule.pendingDeviceAddress = "";
bluetoothModule.pendingDeviceState = "";
isConnecting = false;
}

if (isDisconnecting && !dev.connected) {
bluetoothModule.pendingDeviceAddress = "";
bluetoothModule.pendingDeviceState = "";
isDisconnecting = false;
}

let connectText = dev.connected ? "Desconectar" : "Conectar";
if (isConnecting || isWaitingConnect) connectText = "Conectando...";
else if (isDisconnecting) connectText = "Desconectando...";

let pairText = (dev.bonded || dev.paired) ? "Desparear" : "Parear";
if (isPairing) pairText = "Pareando...";

menuModel.push({
text: "Voltar ao Menu",
preventClose: true,
onTrigger: () => {
bluetoothModule.currentMenuDevice = null;
bluetoothModule.updateMenu(true);
}
});

menuModel.push({ text: `${dev.name || dev.address}`, enabled: false });

if (dev.paired || dev.bonded || isWaitingConnect) {
menuModel.push({
text: connectText,
preventClose: true,
enabled: !isPairing && !isWaitingConnect,
onTrigger: () => {
if (isConnecting || isDisconnecting || isPairing || isWaitingConnect) return;

bluetoothModule.pendingDeviceAddress = dev.address;
bluetoothModule.pendingDeviceState = dev.connected ? "disconnecting" : "connecting";

if (dev.connected) dev.disconnect();
else dev.connect();

bluetoothModule.updateMenu(true);
}
});
}

menuModel.push({
text: pairText,
preventClose: true,
enabled: !isConnecting && !isDisconnecting && !isWaitingConnect,
onTrigger: () => {
if (isPairing || isConnecting || isDisconnecting || isWaitingConnect) return;

if (dev.paired || dev.bonded) {
bluetoothModule.ignoredDevices.push(dev.address);
dev.forget();
bluetoothModule.currentMenuDevice = null;
} else {
bluetoothModule.isPairingProcess = true;
bluetoothModule.pendingDeviceAddress = dev.address;
bluetoothModule.pendingDeviceState = "pairing";
dev.pair();
}
bluetoothModule.updateMenu(true);
}
});

menuModel.push({
text: dev.trusted ? "Desconfiar" : "Confiar",
preventClose: true,
enabled: !isPairing && !isWaitingConnect,
onTrigger: () => {
dev.trusted = !dev.trusted;
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});

return menuModel;
}

function openDeviceSubMenu(dev) {
bluetoothModule.currentMenuDevice = dev;
bluetoothModule.updateMenu(true);
}

function updateMenu(forceOpen) {
if (!bluetoothModule.globalMenu) return;

if (forceOpen && !bluetoothModule.globalMenu.visible) {
bluetoothModule.ignoredDevices = [];
bluetoothModule.pendingDeviceAddress = "";
bluetoothModule.pendingDeviceState = "";
bluetoothModule.deviceToConnectPostPair = null;
bluetoothModule.isPairingProcess = false;
connectionDelayTimer.stop();
}

if (!forceOpen && !bluetoothModule.globalMenu.visible) return;

let modelData = bluetoothModule.currentMenuDevice !== null 
? generateDeviceMenu(bluetoothModule.currentMenuDevice) 
: generateMainMenu();

bluetoothModule.globalMenu.showSearchInput = false;

if (bluetoothModule.globalMenu.visible) {
bluetoothModule.globalMenu.menuModel = modelData;
} else {
bluetoothModule.globalMenu.openMenu(bluetoothModule.parentWindow, bluetoothModule, modelData);
}
}

function getBluetoothState() {
if (!bluetoothModule.isBluetoothOn) return { color: bluetoothModule.disabledColor, text: "off" };

const dev = bluetoothModule.getConnectedDevice();
if (!dev) return { color: bluetoothModule.disconnectedColor, text: "idle" };

if (dev.batteryAvailable) {
return { color: bluetoothModule.connectedColor, text: `up (${Math.round(dev.battery * 100)}%)` };
}

return { color: bluetoothModule.connectedColor, text: "up" };
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
if (bluetoothModule.globalMenu) bluetoothModule.globalMenu.close();
mouse.accepted = true;

if (mouse.button === Qt.LeftButton) {
bluetoothModule.currentMenuDevice = null;
bluetoothModule.updateMenu(true);
} else if (mouse.button === Qt.RightButton && bluetoothModule.adapter) {
bluetoothModule.adapter.enabled = !bluetoothModule.adapter.enabled;
}
}
}

Row {
id: bluetoothRow
anchors.verticalCenter: parent.verticalCenter
readonly property var btState: bluetoothModule.getBluetoothState()

Text {
id: btPrefix
font.family: bluetoothModule.labelFontFamily
font.pixelSize: bluetoothModule.labelFontSize
color: bluetoothModule.labelColor
text: "BT: "
}
Text {
font: btPrefix.font
color: bluetoothRow.btState.color
text: bluetoothRow.btState.text
}
}
}
