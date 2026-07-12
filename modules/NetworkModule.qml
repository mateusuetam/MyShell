import QtQuick
import Quickshell.Networking
import Quickshell.Io
import "../core"

Item {
id: networkModule

required property var globalMenu
required property var parentWindow
required property var passwordPrompt

readonly property bool isWifiOn: Networking.wifiEnabled

property var forgottenNetworks: []

property string lastStatus: ""
property string pendingStatus: ""
property bool isReady: false

property bool isManualBlock: false
readonly property bool isRfkillBlocked: !Networking.wifiHardwareEnabled || isManualBlock

implicitWidth: networkRow.implicitWidth
implicitHeight: networkModule.parentWindow ? networkModule.parentWindow.barHeight : 30

Process {
id: rfkillToggleProcess
}

function toggleRfkill() {
if (networkModule.isManualBlock) {
rfkillToggleProcess.exec(["rfkill", "unblock", "wifi"]);
networkModule.isManualBlock = false;
Networking.wifiEnabled = true;
} else {
rfkillToggleProcess.exec(["rfkill", "block", "wifi"]);
networkModule.isManualBlock = true;
Networking.wifiEnabled = false;
}
networkModule.updateMenu(false);
}

Connections {
target: Networking
function onWifiEnabledChanged() {
if (Networking.wifiEnabled) {
networkModule.isManualBlock = false;
}
networkModule.updateMenu(false);
}
function onWifiHardwareEnabledChanged() {
networkModule.updateMenu(false);
}
}

Component.onCompleted: {
lastStatus = getNetworkState().text;
Qt.callLater(() => { isReady = true; })
}

Process { id: notifyProcess }

Timer {
id: stabilizationTimer
interval: 150
repeat: false
onTriggered: {
networkModule.processFinalStateChange(networkModule.pendingStatus);
}
}

function sendNotification(title, message, urgency) {
notifyProcess.exec(["notify-send", "-u", urgency, title, message]);
}

function handleStateChange(currentText) {
if (!isReady) {
lastStatus = currentText;
return;
}

if (lastStatus === currentText) {
stabilizationTimer.stop();
return;
}

pendingStatus = currentText;
stabilizationTimer.restart();
}

function processFinalStateChange(stableText) {
if (lastStatus === stableText) return;

if (stableText === "up") {
sendNotification("Network", "Conexão estabelecida", "normal");
}
else if (stableText === "off") {
sendNotification("Network", "Wifi desligado", "normal");
}
else if (stableText === "off (B)") {
sendNotification("Network", "Wifi bloqueado", "normal");
}
else if (stableText === "down") {
if (Networking.wifiEnabled && lastStatus === "up") {
sendNotification("Network", "Sem sinal...", "critical");
}
}

lastStatus = stableText;
}

function getWifiDevice() {
var devicesList = Networking.devices.values;
if (!devicesList) return null;
for (var i = 0; i < devicesList.length; i++) {
var dev = devicesList[i];
if (dev && (dev.name.indexOf("wlan") !== -1 || dev.name.indexOf("wlp") !== -1 || dev.type === DeviceType.Wifi)) {
return dev;
}
}
return null;
}

function getActiveDevice() {
var devicesList = Networking.devices.values;
if (!devicesList) return null;
for (var i = 0; i < devicesList.length; i++) {
var dev = devicesList[i];
if (dev && dev.connected) {
return dev;
}
}
return null;
}

function generateMainMenu() {
let menuModel = [];

if (!Networking.wifiEnabled) {
menuModel.push({
text: "Ligar Wi-Fi",
enabled: !networkModule.isRfkillBlocked,
onTrigger: () => { Networking.wifiEnabled = true; }
});

menuModel.push({
text: networkModule.isRfkillBlocked ? "Desbloquear Wi-Fi" : "Bloquear Wi-Fi",
preventClose: true,
onTrigger: () => networkModule.toggleRfkill()
});

} else {
menuModel.push({
text: "Desligar Wi-Fi",
onTrigger: () => { Networking.wifiEnabled = false; }
});

menuModel.push({
text: "Bloquear Wi-Fi",
preventClose: true,
onTrigger: () => networkModule.toggleRfkill()
});

menuModel.push({
text: "Buscar Redes",
preventClose: true,
onTrigger: () => {
if (networkModule.globalMenu) {
networkModule.globalMenu.pushMenu(
networkModule.generateScanMenu(),
"scan",
() => networkModule.generateScanMenu()
);
}
}
});

menuModel.push({ type: "separator" });

let wifiDev = networkModule.getWifiDevice();
if (wifiDev && wifiDev.networks && wifiDev.networks.values) {
let nets = wifiDev.networks.values;
for (let i = 0; i < nets.length; i++) {
let net = nets[i];
if (net && (net.known || net.connected)) {
if (networkModule.forgottenNetworks.indexOf(net.name) !== -1) continue;
let prefix = net.connected ? "! Conectado: " : "? ";
menuModel.push({
text: prefix + net.name,
preventClose: true,
onTrigger: () => {
if (networkModule.globalMenu) {
networkModule.globalMenu.pushMenu(
networkModule.generateActionMenu(net),
"action_" + net.name,
() => networkModule.generateActionMenu(net)
);
}
}
});
}
}
}
}
return menuModel;
}

function generateScanMenu() {
let menuModel = [];
let wifiDev = networkModule.getWifiDevice();

if (wifiDev) wifiDev.scannerEnabled = true;

menuModel.push({
text: "Atualizar Busca",
preventClose: true,
onTrigger: () => {
if (wifiDev) {
wifiDev.scannerEnabled = false;
wifiDev.scannerEnabled = true;
}
networkModule.updateMenu(false);
}
});

menuModel.push({ type: "separator" });

if (wifiDev && wifiDev.networks && wifiDev.networks.values) {
let nets = wifiDev.networks.values;
let sortedNets = nets.slice().sort((a, b) => b.signalStrength - a.signalStrength);

for (let i = 0; i < sortedNets.length; i++) {
let net = sortedNets[i];
if (!net.name || networkModule.forgottenNetworks.indexOf(net.name) !== -1) continue;

let signalIcon = "2";
if (net.signalStrength >= 0.8) signalIcon = "8";
else if (net.signalStrength >= 0.6) signalIcon = "6";
else if (net.signalStrength >= 0.4) signalIcon = "4";

let secIcon = (net.security === WifiSecurityType.Open) ? "NOPWD" : "PWD";
let activeIcon = net.connected ? "! " : "";

menuModel.push({
text: `${activeIcon}${signalIcon} ${net.name} - ${secIcon}`,
onTrigger: () => {
if (net.known || net.security === WifiSecurityType.Open) {
net.connect();
} else {
networkModule.globalMenu.close();
Qt.callLater(() => {
networkModule.passwordPrompt.openPrompt(net, networkModule.parentWindow);
});
}
}
});
}
}
return menuModel;
}

function generateActionMenu(net) {
let menuModel = [];
if (!net) return menuModel;

menuModel.push({ text: `${net.name}`, enabled: false });

menuModel.push({
text: net.connected ? "Desconectar" : "Conectar",
preventClose: true,
onTrigger: () => {
if (net.connected) net.disconnect();
else net.connect();
networkModule.globalMenu.popMenu();
}
});

menuModel.push({
text: "Esquecer",
preventClose: true,
onTrigger: () => {
let netName = net.name;
if (networkModule.forgottenNetworks.indexOf(netName) === -1) {
networkModule.forgottenNetworks.push(netName);
}
net.forget();
networkModule.globalMenu.popMenu();
}
});

return menuModel;
}

function updateMenu(forceOpen) {
if (!networkModule.globalMenu) return;
if (!forceOpen && !networkModule.globalMenu.visible) return;

networkModule.globalMenu.showSearchInput = false;

if (networkModule.globalMenu.visible) {
networkModule.globalMenu.refresh();
} else {
networkModule.globalMenu.openMenu(
networkModule.parentWindow,
networkModule,
networkModule.generateMainMenu(),
"main",
() => networkModule.generateMainMenu()
);
}
}

function getNetworkState() {
if (networkModule.isRfkillBlocked) {
return { color: ThemeRegistry.networkDisabledColor, text: "off (B)" };
}
if (!networkModule.isWifiOn) {
return { color: ThemeRegistry.networkDisabledColor, text: "off" };
}
const dev = networkModule.getActiveDevice();
if (!dev) {
return { color: ThemeRegistry.networkDisconnectedColor, text: "down" };
}
return { color: ThemeRegistry.networkConnectedColor, text: "up" };
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onPressed: mouse => {
if (networkModule.globalMenu) networkModule.globalMenu.close();
mouse.accepted = true;

if (mouse.button === Qt.LeftButton) {
networkModule.forgottenNetworks = [];
networkModule.updateMenu(true);
} else if (mouse.button === Qt.RightButton) {
if (!networkModule.isRfkillBlocked) {
Networking.wifiEnabled = !Networking.wifiEnabled;
}
}
}
}

Row {
id: networkRow
anchors.verticalCenter: parent.verticalCenter
readonly property var nwState: networkModule.getNetworkState()
readonly property string stateText: nwState.text

onStateTextChanged: {
networkModule.handleStateChange(stateText);
}

Text {
id: networkPrefix
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
color: ThemeRegistry.networkLabelColor
text: "NW: "
}
Text {
font: networkPrefix.font
color: networkRow.nwState.color
text: networkRow.stateText
}
}
}
