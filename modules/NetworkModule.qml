import QtQuick
import Quickshell.Networking
import Quickshell.Io
import "../components/themeengine"
import "../components/popupmenu"

Item {
id: networkModule

required property var globalMenu
required property var parentWindow

readonly property color disabledColor: ThemeRegistry.networkDisabledColor
readonly property color disconnectedColor: ThemeRegistry.networkDisconnectedColor
readonly property color connectedColor: ThemeRegistry.networkConnectedColor
readonly property color labelColor: ThemeRegistry.networkLabelColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

readonly property bool isWifiOn: Networking.wifiEnabled

property string currentSubMenu: "main"
property var selectedNetwork: null
property var forgottenNetworks: []

property string lastStatus: ""
property string pendingStatus: ""
property bool isReady: false

implicitWidth: networkRow.implicitWidth
implicitHeight: networkModule.parentWindow ? networkModule.parentWindow.barHeight : 30

Component.onCompleted: {
lastStatus = getNetworkState().text
Qt.callLater(() => { isReady = true; })
}

PasswordPrompt { id: wifiPasswordPrompt }
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
sendNotification("Network", "Conexão estabelecida", "low");
}
else if (stableText === "off") {
sendNotification("Network", "Wifi desligado", "low");
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

function getWifiName(dev) {
if (!dev || !dev.networks || !dev.networks.values) return "wifi";
var networksList = dev.networks.values;
for (var j = 0; j < networksList.length; j++) {
var net = networksList[j];
if (net && net.connected && net.name) {
return net.name;
}
}
return "wifi";
}

function generateMainMenu() {
let menuModel = [];

if (!Networking.wifiEnabled) {
menuModel.push({
text: "Ligar Wi-Fi",
onTrigger: () => { Networking.wifiEnabled = true; }
});
} else {
menuModel.push({
text: "Desligar Wi-Fi",
onTrigger: () => { Networking.wifiEnabled = false; }
});
menuModel.push({
text: "Buscar Redes",
preventClose: true,
onTrigger: () => {
networkModule.currentSubMenu = "scan";
networkModule.updateMenu(true);
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
networkModule.selectedNetwork = net;
networkModule.currentSubMenu = "action";
networkModule.updateMenu(true);
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

if (wifiDev) {
wifiDev.scannerEnabled = true;
}

menuModel.push({
text: "Atualizar Busca",
preventClose: true,
onTrigger: () => {
if (wifiDev) {
wifiDev.scannerEnabled = false;
wifiDev.scannerEnabled = true;
}
networkModule.updateMenu(true);
}
});
menuModel.push({
text: "Voltar",
preventClose: true,
onTrigger: () => {
networkModule.currentSubMenu = "main";
networkModule.updateMenu(true);
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
wifiPasswordPrompt.openPrompt(net, networkModule.parentWindow);
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
networkModule.currentSubMenu = "main";
networkModule.selectedNetwork = null;
networkModule.updateMenu(true);
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
networkModule.currentSubMenu = "main";
networkModule.selectedNetwork = null;
networkModule.updateMenu(true);
}
});

menuModel.push({ type: "separator" });
menuModel.push({
text: "Voltar",
preventClose: true,
onTrigger: () => {
networkModule.selectedNetwork = null;
networkModule.currentSubMenu = "main";
networkModule.updateMenu(true);
}
});
return menuModel;
}

function updateMenu(forceOpen) {
if (!networkModule.globalMenu) return;

if (forceOpen && !networkModule.globalMenu.visible) {
networkModule.currentSubMenu = "main";
networkModule.selectedNetwork = null;
}

if (!forceOpen && !networkModule.globalMenu.visible) return;

let modelData = [];
if (networkModule.currentSubMenu === "scan") {
modelData = networkModule.generateScanMenu();
} else if (networkModule.currentSubMenu === "action" && networkModule.selectedNetwork !== null) {
modelData = networkModule.generateActionMenu(networkModule.selectedNetwork);
} else {
modelData = networkModule.generateMainMenu();
}

networkModule.globalMenu.showSearchInput = false;

if (networkModule.globalMenu.visible) {
networkModule.globalMenu.menuModel = modelData;
} else {
networkModule.globalMenu.openMenu(networkModule.parentWindow, networkModule, modelData);
}
}

function getNetworkState() {
if (!networkModule.isWifiOn) {
return { color: networkModule.disabledColor, text: "off" };
}
const dev = networkModule.getActiveDevice();
if (!dev) {
return { color: networkModule.disconnectedColor, text: "down" };
}
return { color: networkModule.connectedColor, text: "up" };
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
let menu = networkModule.globalMenu;
if (menu) menu.close();
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
networkModule.forgottenNetworks = [];
networkModule.currentSubMenu = "main";
networkModule.selectedNetwork = null;
networkModule.updateMenu(true);
} else if (mouse.button === Qt.RightButton) {
Networking.wifiEnabled = !Networking.wifiEnabled;
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
font.family: networkModule.labelFontFamily
font.pixelSize: networkModule.labelFontSize
color: networkModule.labelColor
text: "NW: "
}
Text {
font: networkPrefix.font
color: networkRow.nwState.color
text: networkRow.stateText
}
}
}
