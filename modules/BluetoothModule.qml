pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Quickshell.Bluetooth
import Quickshell.Io
import "../core"

Item {
id: bluetoothModule

required property var globalMenu
required property var parentWindow

readonly property bool isBluetoothOn: (() => {
const adapter = Bluetooth["defaultAdapter"];
return adapter ? adapter["enabled"] : false;
})()

implicitWidth: bluetoothRow.implicitWidth
implicitHeight: bluetoothModule.parentWindow ? bluetoothModule.parentWindow.barHeight : 30

property string pendingOpAddress: ""
property string pendingOpState: ""
property string imunityAddress: ""
property bool justPairedImunity: false
property bool startAgent: false

property bool isRfkillBlocked: false

function getBackButton(text) {
return {
text: text,
preventClose: true,
__fixedFooter: true,
onTrigger: () => {
if (bluetoothModule.globalMenu) bluetoothModule.globalMenu.popMenu();
}
};
}

function openDeviceSubMenu(dev) {
if (!bluetoothModule.globalMenu || !dev) return;
bluetoothModule.globalMenu.pushMenu(bluetoothModule.generateDeviceMenu(dev), "device_" + dev.address, () => bluetoothModule.generateDeviceMenu(dev));
}

Process {
id: notifyProcess
}

function sendNotification(title, message, urgency) {
notifyProcess.exec(["notify-send", "-u", urgency, title, message]);
}

Process {
id: bluetoothAgentDaemon
command: ["bluetoothctl", "--agent", "NoInputNoOutput"]
running: bluetoothModule.startAgent
}

Process {
id: rfkillCheckProcess
command: ["sh", "-c", "for d in /sys/class/rfkill/rfkill*; do if [ -f \"$d/type\" ] && [ \"$(cat \"$d/type\")\" = \"bluetooth\" ]; then if [ \"$(cat \"$d/soft\")\" = \"1\" ] || [ \"$(cat \"$d/hard\")\" = \"1\" ]; then echo \"yes\"; exit 0; fi; fi; done; echo \"no\""]
stdout: StdioCollector {
onStreamFinished: {
const output = this.text.trim().toLowerCase();
bluetoothModule.isRfkillBlocked = output === "yes";
bluetoothModule.updateMenu(false);
}
}
}

Process {
id: rfkillToggleProcess
onRunningChanged: {
if (!running) bluetoothModule.checkRfkill();
}
}

function checkRfkill() {
if (!rfkillCheckProcess.running) rfkillCheckProcess.exec(rfkillCheckProcess.command);
}

function toggleRfkill() {
if (bluetoothModule.isRfkillBlocked) {
rfkillToggleProcess.exec(["rfkill", "unblock", "bluetooth"]);
} else {
rfkillToggleProcess.exec(["rfkill", "block", "bluetooth"]);
bluetoothModule.sendNotification("Bluetooth", "Bluetooth bloqueado", "normal");
}
}

Timer {
id: pairingTimeoutTimer
interval: 8000
repeat: false
onTriggered: {
if (bluetoothModule.pendingOpState === "pairing") {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
bluetoothModule.updateMenu(false);
}
}
}

Timer {
id: imunityTimer
interval: 6000
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
if (adapter && adapter["discovering"]) adapter["discovering"] = false;
}
}

Component.onCompleted: {
bluetoothModule.startAgent = true;
bluetoothModule.checkRfkill();
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
bluetoothModule.updateMenu(false);
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

bluetoothModule.updateMenu(false);
return;
}

if (bluetoothModule.pendingOpAddress === dev.address && (bluetoothModule.pendingOpState === "connecting" || bluetoothModule.pendingOpState === "disconnecting")) {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

const devName = dev.name || dev.address;

bluetoothModule.sendNotification("Bluetooth", (dev.connected ? "Conectado: " : "Desconectado: ") + devName, "normal");

bluetoothModule.updateMenu(false);
}

function onBondedChanged() {
const dev = devConn.modelData;
if (!dev) return;

if (dev.bonded && !dev.trusted) dev.trusted = true;

if (dev.bonded && bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "pairing") {
bluetoothModule.imunityAddress = dev.address;
bluetoothModule.justPairedImunity = true;

imunityTimer.restart();
}

bluetoothModule.updateMenu(false);
}

function onPairedChanged() {
bluetoothModule.updateMenu(false);
}

function onTrustedChanged() {
bluetoothModule.updateMenu(false);
}
}
}

Connections {
target: Bluetooth["defaultAdapter"] ? Bluetooth["defaultAdapter"] : null

function onEnabledChanged() {
bluetoothModule.updateMenu(false);
bluetoothModule.checkRfkill();
}

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

function getBluetoothState() {
if (!bluetoothModule.isBluetoothOn) {
const offText = bluetoothModule.isRfkillBlocked ? "off (B)" : "off";

return {
color: ThemeEngine.palette.bluetoothDisabledColor,
text: offText
};
}

const dev = bluetoothModule.getConnectedDevice();

if (!dev) {
return {
color: ThemeEngine.palette.bluetoothDisconnectedColor,
text: "idle"
};
}

if (dev.batteryAvailable) {
return {
color: ThemeEngine.palette.bluetoothConnectedColor,
text: `up ${Math.round(dev.battery * 100)}%`
};
}

return {
color: ThemeEngine.palette.bluetoothConnectedColor,
text: "up"
};
}

function generateMainMenu() {
let menuModel = [];

const adapter = Bluetooth["defaultAdapter"];

if (!bluetoothModule.isBluetoothOn) {
menuModel.push({
text: "Ligar Bluetooth",
enabled: !bluetoothModule.isRfkillBlocked,
onTrigger: () => {
if (adapter) adapter["enabled"] = true;
}
});

menuModel.push({
text: bluetoothModule.isRfkillBlocked ? "Desbloquear Bluetooth" : "Bloquear Bluetooth",
preventClose: true,
onTrigger: () => bluetoothModule.toggleRfkill()
});

return menuModel;
}

menuModel.push({
text: "Desligar Bluetooth",
onTrigger: () => {
if (adapter) adapter["enabled"] = false;
}
});

menuModel.push({
text: "Bloquear Bluetooth",
preventClose: true,
onTrigger: () => bluetoothModule.toggleRfkill()
});

menuModel.push({
text: adapter && adapter["discovering"] ? "Parar Busca" : "Buscar Dispositivos",
preventClose: true,
onTrigger: () => {
if (adapter) adapter["discovering"] = !adapter["discovering"];
}
});

const devices = Bluetooth["devices"];
const list = devices ? (devices["values"] ?? []) : [];

let pairedDevices = [];
let newDevices = [];

for (let i = 0; i < list.length; ++i) {
const dev = list[i];

if (!dev) continue;

if (dev.bonded) {
pairedDevices.push(dev);
} else if (adapter && adapter["discovering"]) {
newDevices.push(dev);
}
}

if (pairedDevices.length > 0) {
menuModel.push({ type: "separator" });

for (let i = 0; i < pairedDevices.length; ++i) {
const dev = pairedDevices[i];

let label = (dev.connected ? "Conectado: " : "Desconectado: ") + (dev.name || dev.address);

if (dev.connected && dev.batteryAvailable) label += ` (${Math.round(dev.battery * 100)}%)`;

menuModel.push({
text: label,
preventClose: true,
onTrigger: () => bluetoothModule.openDeviceSubMenu(dev)
});
}
}

if (newDevices.length > 0) {
menuModel.push({ type: "separator" });

for (let i = 0; i < newDevices.length; ++i) {
const dev = newDevices[i];

menuModel.push({
text: dev.name || dev.address,
preventClose: true,
onTrigger: () => bluetoothModule.openDeviceSubMenu(dev)
});
}
}

return menuModel;
}

function generateDeviceMenu(dev) {
let menuModel = [];

if (!dev) return menuModel;

const isConnecting = bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "connecting";
const isDisconnecting = bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "disconnecting";
const isPairing = bluetoothModule.pendingOpAddress === dev.address && bluetoothModule.pendingOpState === "pairing";

menuModel.push({
text: `${dev.name || dev.address}`,
enabled: false
});

if (isPairing) {
menuModel.push({
text: "Pareando...",
enabled: false,
preventClose: true
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
if (dev.connected){
dev.disconnect();
} else {
dev.connect();
}
} catch (e) {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

Qt.callLater(() => bluetoothModule.updateMenu(false));
}
});

menuModel.push({
text: "Desparear",
preventClose: true,
onTrigger: () => {
try {
dev.forget();
} catch (e) {}
bluetoothModule.globalMenu.popMenu();
}
});

menuModel.push({
text: dev.trusted ? "Desconfiar" : "Confiar",
preventClose: true,
onTrigger: () => {
dev.trusted = !dev.trusted;
Qt.callLater(() => bluetoothModule.updateMenu(false));
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

try {
dev.pair();
} catch (e) {
pairingTimeoutTimer.stop();
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

Qt.callLater(() => bluetoothModule.updateMenu(false));
}
});
}

menuModel.push(bluetoothModule.getBackButton("< Bluetooth"));

return menuModel;
}

function updateMenu(forceOpen) {
if (!bluetoothModule.globalMenu) return;

if (forceOpen && !bluetoothModule.globalMenu.visible) {
bluetoothModule.pendingOpAddress = "";
bluetoothModule.pendingOpState = "";
}

if (!forceOpen) {
if (!bluetoothModule.globalMenu.visible || bluetoothModule.globalMenu._currentAnchorItem !== bluetoothModule) return;
}

bluetoothModule.globalMenu.showSearchInput = false;

if (bluetoothModule.globalMenu.visible && bluetoothModule.globalMenu._currentAnchorItem === bluetoothModule) {
bluetoothModule.globalMenu.refresh();
} else {
bluetoothModule.globalMenu.openMenu(bluetoothModule.parentWindow, bluetoothModule, bluetoothModule.generateMainMenu(), "main", () => bluetoothModule.generateMainMenu());
}
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onPressed: mouse => {
let menu = bluetoothModule.globalMenu;

mouse.accepted = true;

if (menu && !menu.shouldOpenFor(bluetoothModule)) return;

bluetoothModule.checkRfkill();

if (mouse.button === Qt.LeftButton) {
Qt.callLater(() => bluetoothModule.updateMenu(true));
} else if (mouse.button === Qt.RightButton) {
const adapter = Bluetooth["defaultAdapter"];

if (!adapter) return;

if (adapter["enabled"]) {
adapter["enabled"] = false;
} else if (!bluetoothModule.isRfkillBlocked) {
adapter["enabled"] = true;
}
}
}
}

Row {
id: bluetoothRow

anchors.verticalCenter: parent.verticalCenter

readonly property var btState:
bluetoothModule.getBluetoothState()

Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: bluetoothRow.btState.color
text: `BT: ${bluetoothRow.btState.text}`
}
}
}
