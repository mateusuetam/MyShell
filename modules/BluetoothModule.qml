pragma ComponentBehavior: Bound
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

readonly property bool isBluetoothOn: (() => {
const adapter = Bluetooth["defaultAdapter"];
return adapter ? adapter["enabled"] : false;
})()

implicitWidth: bluetoothRow.implicitWidth
implicitHeight: bluetoothModule.parentWindow ? bluetoothModule.parentWindow.barHeight : 30

property var currentMenuDevice: null

property string pendingOpAddress: ""
property string pendingOpState: ""

property string imunityAddress: ""
property bool justPairedImunity: false

property bool startAgent: false

Process { id: notifyProcess }

function sendNotification(title, message, urgency) {
notifyProcess.exec(["notify-send", "-u", urgency, title, message]);
}

Process {
id: bluetoothAgentDaemon
command: ["bluetoothctl", "--agent", "NoInputNoOutput"]
running: bluetoothModule.startAgent
}

Component.onCompleted: {
bluetoothModule.startAgent = true;
}

Timer {
id: pairingTimeoutTimer
interval: 8000
repeat: false
onTriggered: {
if (bluetoothModule.pendingOpState === "pairing") {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
bluetoothModule.updateMenu(true);
}
}
}

Timer {
id: imunityTimer
interval: 3000
repeat: false
onTriggered: {
bluetoothModule.justPairedImunity = false;
bluetoothModule.imunityAddress = "";
}
}

Timer {
id: discoveryTimeoutTimer
interval: 60000
repeat: false
onTriggered: {
const adapter = Bluetooth["defaultAdapter"];
if (adapter && adapter["discovering"]) {
adapter["discovering"] = false;
}
}
}

Instantiator {
model: Bluetooth["devices"] ? Bluetooth["devices"]["values"] : []

onObjectAdded: (index, object) => bluetoothModule.updateMenu(false)
onObjectRemoved: (index, object) => bluetoothModule.updateMenu(false)

delegate: Connections {
id: devConn
required property var modelData
target: devConn.modelData

function onConnectedChanged() {
const dev = devConn.modelData;
if (!dev) return;

if (!dev.connected && bluetoothModule.justPairedImunity && bluetoothModule.imunityAddress === dev.address) {
bluetoothModule.updateMenu(true);
return;
}

if (bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "pairing") {
if (!dev.connected) {
pairingTimeoutTimer.stop();

bluetoothModule.imunityAddress = dev.address;
bluetoothModule.justPairedImunity = true;
imunityTimer.restart();

bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}
bluetoothModule.updateMenu(true);
return;
}

if (bluetoothModule.pendingOpAddress === dev.address &&
(bluetoothModule.pendingOpState === "connecting" || bluetoothModule.pendingOpState === "disconnecting")) {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

let devName = dev.name || dev.address;
bluetoothModule.sendNotification("Bluetooth", (dev.connected ? "Conectado: " : "Desconectado: ") + devName, "low");
bluetoothModule.updateMenu(true);
}

function onBondedChanged() {
const dev = devConn.modelData;
if (!dev) return;

if (dev.bonded && !dev.trusted) {
dev.trusted = true;
}

if (dev.bonded && bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "pairing") {
bluetoothModule.imunityAddress = dev.address;
bluetoothModule.justPairedImunity = true;
imunityTimer.restart();
}

bluetoothModule.updateMenu(true);
}

function onPairedChanged() { bluetoothModule.updateMenu(true); }
function onTrustedChanged() { bluetoothModule.updateMenu(true); }
}
}

Connections {
target: Bluetooth["defaultAdapter"] ? Bluetooth["defaultAdapter"] : null
function onEnabledChanged() { bluetoothModule.updateMenu(false); }
function onDiscoveringChanged() {
const adapter = Bluetooth["defaultAdapter"];
if (adapter && adapter["discovering"]) {
discoveryTimeoutTimer.restart();
} else {
discoveryTimeoutTimer.stop();
}
bluetoothModule.updateMenu(false);
}
}

function getConnectedDevice() {
const devices = Bluetooth["devices"];
const list = devices ? (devices["values"] ?? []) : [];
for (let i = 0; i < list.length; ++i) {
const dev = list[i];
if (dev?.connected) return dev;
}
return null;
}

function generateMainMenu() {
let menuModel = [];
const adapter = Bluetooth["defaultAdapter"];

if (!bluetoothModule.isBluetoothOn) {
menuModel.push({ text: "Ligar Bluetooth", onTrigger: () => { if (adapter) adapter["enabled"] = true; } });
return menuModel;
}

menuModel.push({ text: "Desligar Bluetooth", onTrigger: () => { if (adapter) adapter["enabled"] = false; } });
menuModel.push({
text: adapter && adapter["discovering"] ? "Parar Busca" : "Iniciar Busca",
preventClose: true,
onTrigger: () => { if (adapter) adapter["discovering"] = !adapter["discovering"]; }
});

const devices = Bluetooth["devices"];
const list = devices ? (devices["values"] ?? []) : [];
let pairedDevices = [];
let newDevices = [];

for (let i = 0; i < list.length; i++) {
let mainDev = list[i];
if (!mainDev) continue;

if (mainDev.bonded) {
pairedDevices.push(mainDev);
} else if (adapter && adapter["discovering"]) {
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
onTrigger: () => { bluetoothModule.openDeviceSubMenu(pDev); }
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
onTrigger: () => { bluetoothModule.openDeviceSubMenu(nDev); }
});
}
}

return menuModel;
}

function generateDeviceMenu(dev) {
let menuModel = [];
if (!dev) return menuModel;

let isConnecting = (bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "connecting");
let isDisconnecting = (bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "disconnecting");
let isPairing = (bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "pairing");

menuModel.push({
text: "Voltar ao Menu",
preventClose: true,
enabled: !isPairing,
onTrigger: () => {
bluetoothModule.currentMenuDevice = null;
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});

menuModel.push({ text: `${dev.name || dev.address}`, enabled: false });

if (isPairing) {
menuModel.push({
text: "Pareando...",
preventClose: true,
enabled: false,
onTrigger: () => {}
});
} else if (dev.bonded) {
let connectText = dev.connected ? "Desconectar" : "Conectar";
if (isConnecting) connectText = "Conectando...";
if (isDisconnecting) connectText = "Desconectando...";

menuModel.push({
text: connectText,
preventClose: true,
enabled: !isConnecting && !isDisconnecting,
onTrigger: () => {
if (isConnecting || isDisconnecting) return;

bluetoothModule.pendingOpAddress = dev.address;
bluetoothModule.pendingOpState = dev.connected ? "disconnecting" : "connecting";

try {
if (dev.connected) dev.disconnect();
else dev.connect();
} catch(e) {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});

menuModel.push({
text: "Desparear",
preventClose: true,
onTrigger: () => {
try { dev.forget(); } catch(e) {}
bluetoothModule.currentMenuDevice = null;
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});

menuModel.push({
text: dev.trusted ? "Desconfiar" : "Confiar",
preventClose: true,
onTrigger: () => {
dev.trusted = !dev.trusted;
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});
} else {
menuModel.push({
text: "Parear",
preventClose: true,
enabled: true,
onTrigger: () => {
bluetoothModule.pendingOpAddress = dev.address;
bluetoothModule.pendingOpState = "pairing";
pairingTimeoutTimer.restart();

try { dev.pair(); } catch(e) {
pairingTimeoutTimer.stop();
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}
Qt.callLater(() => bluetoothModule.updateMenu(true));
}
});
}

return menuModel;
}

function openDeviceSubMenu(dev) {
bluetoothModule.currentMenuDevice = dev;
Qt.callLater(() => bluetoothModule.updateMenu(true));
}

function updateMenu(forceOpen) {
if (!bluetoothModule.globalMenu) return;

if (forceOpen && !bluetoothModule.globalMenu.visible) {
bluetoothModule.currentMenuDevice = null;
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

if (!forceOpen && !bluetoothModule.globalMenu.visible) return;

let modelData = bluetoothModule.currentMenuDevice !== null
? bluetoothModule.generateDeviceMenu(bluetoothModule.currentMenuDevice)
: bluetoothModule.generateMainMenu();

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
Qt.callLater(() => bluetoothModule.updateMenu(true));
} else if (mouse.button === Qt.RightButton) {
const adapter = Bluetooth["defaultAdapter"];
if (adapter) {
adapter["enabled"] = !adapter["enabled"];
}
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
