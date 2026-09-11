pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Networking
import Quickshell.Io
import "../core"

Item {
id: networkModule

required property var globalMenu
required property var parentWindow
required property var textPrompt

property var forgottenNetworks: []
property var pendingNetworkForAuth: null

property string lastStatus: ""
property string pendingStatus: ""

property bool isReady: false
property bool isManualBlock: false

readonly property bool isWifiOn: Networking.wifiEnabled
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
if (isWifiOn) {
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
Qt.callLater(() => { isReady = true; });
}

Process { id: notifyProcess }

Connections {
target: networkModule.pendingNetworkForAuth
ignoreUnknownSignals: true
function onConnectedChanged() {
if (networkModule.pendingNetworkForAuth?.connected) {
networkAuthWatchdog.stop();
networkModule.textPrompt.closePrompt();
networkModule.pendingNetworkForAuth = null;
}
}
}

Timer {
id: networkAuthWatchdog
interval: 5000
repeat: false
onTriggered: {
if (networkModule.pendingNetworkForAuth && !networkModule.pendingNetworkForAuth.connected) {
networkModule.textPrompt.showError("Falha na conexão. Tente novamente:");
}
}
}

Timer {
id: promptDelayTimer
interval: 150
repeat: false
onTriggered: {
if (networkModule.pendingNetworkForAuth) {
let netName = networkModule.pendingNetworkForAuth.name;

networkModule.textPrompt.openPrompt(`Senha para ${netName}:`, networkModule.parentWindow, true,
(inputText) => {networkModule.pendingNetworkForAuth.connectWithPsk(inputText); networkAuthWatchdog.start();},
`Conectando a ${netName}...`);
}
}
}

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

switch (stableText) {
case "up":
sendNotification("Network", "Conexão estabelecida", "normal");
break;
case "off":
sendNotification("Network", "Wifi desligado", "normal");
break;
case "off (B)":
sendNotification("Network", "Wifi bloqueado", "normal");
break;
case "down":
if (isWifiOn && lastStatus === "up") {
sendNotification("Network", "Sem sinal...", "critical");
}
break;
}

lastStatus = stableText;
}

function getWifiDevice() {
const devicesList = Networking.devices?.values;
if (!devicesList) return null;
return devicesList.find(dev => dev && (dev.name.includes("wlan") || dev.name.includes("wlp") || dev.type === DeviceType.Wifi)) || null;
}

function getActiveDevice() {
const devicesList = Networking.devices?.values;
if (!devicesList) return null;
return devicesList.find(dev => dev?.connected) || null;
}

function getBackButton() {
return {
text: "< Menu de redes",
preventClose: true,
__fixedFooter: true,
onTrigger: () => {
if (networkModule.globalMenu) networkModule.globalMenu.popMenu();
}
};
}

function generateMainMenu() {
let menuModel = [];

menuModel.push({
text: isWifiOn ? "Desligar Wi-Fi" : "Ligar Wi-Fi",
enabled: !networkModule.isRfkillBlocked,
onTrigger: () => { Networking.wifiEnabled = !isWifiOn; }
});

menuModel.push({
text: networkModule.isRfkillBlocked ? "Desbloquear Wi-Fi" : "Bloquear Wi-Fi",
preventClose: true,
onTrigger: () => networkModule.toggleRfkill()
});

if (isWifiOn) {
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
let nets = wifiDev?.networks?.values;

if (nets) {
for (let i = 0; i < nets.length; i++) {
let net = nets[i];

if (net && (net.known || net.connected)) {
if (networkModule.forgottenNetworks.includes(net.name)) continue;

let prefix = net.connected ? "Conectado: " : "Desconectado: ";

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

Connections {
target: networkModule.globalMenu
function onVisibleChanged() {
if (!networkModule.globalMenu?.visible) {
let wifiDev = networkModule.getWifiDevice();
if (wifiDev && wifiDev.scannerEnabled) {
wifiDev.scannerEnabled = false;
}
}
}
}

function generateScanMenu() {
let menuModel = [];
let wifiDev = networkModule.getWifiDevice();

if (wifiDev) wifiDev.scannerEnabled = true;

menuModel.push({
text: "Atualizar Busca",
preventClose: true,
__fixedHeader: true,
onTrigger: () => {
const dev = networkModule.getWifiDevice();
if (dev) {
dev.scannerEnabled = false;
dev.scannerEnabled = true;
}
networkModule.updateMenu(false);
}
});

let nets = wifiDev?.networks?.values;
if (nets) {
let sortedNets = nets.slice().sort((a, b) => b.signalStrength - a.signalStrength);

for (let i = 0; i < sortedNets.length; i++) {
let net = sortedNets[i];

if (!net.name || networkModule.forgottenNetworks.includes(net.name)) continue;

let signalIcon = "2";
if (net.signalStrength >= 0.8) signalIcon = "8";
else if (net.signalStrength >= 0.6) signalIcon = "6";
else if (net.signalStrength >= 0.4) signalIcon = "4";

let secIcon = net.security === WifiSecurityType.Open ? "NOPWD" : "PWD";

menuModel.push({
text: `${net.name} | ${secIcon} | ${signalIcon}`,
onTrigger: () => {
if (net.known || net.security === WifiSecurityType.Open) {
net.connect();
} else {
networkModule.globalMenu.close();
networkModule.pendingNetworkForAuth = net;
promptDelayTimer.start();
}
}
});
}
}

menuModel.push(networkModule.getBackButton());

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
if (!networkModule.forgottenNetworks.includes(netName)) {
networkModule.forgottenNetworks.push(netName);
}
net.forget();
networkModule.globalMenu.popMenu();
}
});

menuModel.push(networkModule.getBackButton());

return menuModel;
}

function updateMenu(forceOpen) {
if (!networkModule.globalMenu) return;
if (!forceOpen && !networkModule.globalMenu.visible) return;

networkModule.globalMenu.showSearchInput = false;

if (networkModule.globalMenu.visible && networkModule.globalMenu._currentAnchorItem === networkModule) {
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
return { color: ThemeEngine.palette.networkDisabledColor, text: "off (B)" };
}
if (!isWifiOn) {
return { color: ThemeEngine.palette.networkDisabledColor, text: "off" };
}
const dev = networkModule.getActiveDevice();
if (!dev) {
return { color: ThemeEngine.palette.networkDisconnectedColor, text: "down" };
}
return { color: ThemeEngine.palette.networkConnectedColor, text: "up" };
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onPressed: mouse => {
let menu = networkModule.globalMenu;
mouse.accepted = true;

if (menu && !menu.shouldOpenFor(networkModule)) return;

if (mouse.button === Qt.LeftButton) {
networkModule.forgottenNetworks = [];
networkModule.updateMenu(true);
} else if (mouse.button === Qt.RightButton) {
if (!networkModule.isRfkillBlocked) {
Networking.wifiEnabled = !isWifiOn;
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
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: networkRow.nwState.color
text: `NW: ${networkRow.stateText}`
}
}
}
