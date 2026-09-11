pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "../core"

Item {
id: backlightModule

required property var globalMenu
required property var parentWindow
required property var textPrompt

property int brightnessPercent: 50
property int targetTemp: 2500

implicitWidth: backlightRow.implicitWidth
implicitHeight: backlightModule.parentWindow ? backlightModule.parentWindow.barHeight : 30

Process {
id: readBrightness
command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
stdout: StdioCollector {
onStreamFinished: {
var val = parseInt(this.text.trim());
if (!isNaN(val)) backlightModule.brightnessPercent = val;
}
}
Component.onCompleted: readBrightness.running = true
}

Process {
id: changeBrightness
}

Connections {
target: changeBrightness
function onExited() {
readBrightness.running = true;
}
}

Process {
id: checkGammastep
command: ["pgrep", "-f", "gammastep"]
}

Connections {
target: checkGammastep
function onExited(exitCode) {
backlightModule.updateMenu(exitCode === 0);
}
}

Process {
id: gammastepToggleCheck
command: ["pgrep", "-f", "gammastep"]
}

Process {
id: gammastepKill
command: ["pkill", "-f", "gammastep"]
}

Process {
id: gammastepStart
command: ["sh", "-c", "notify-send -u low Gammastep 'Temperatura ajustada para 2500K' && gammastep -O 2500"]
}

Connections {
target: gammastepToggleCheck
function onExited(exitCode) {
if (exitCode === 0) {
gammastepKill.running = true;
} else {
gammastepStart.running = true;
}
}
}

Process {
id: applyGammastepKill
command: ["pkill", "-f", "gammastep"]
}

Process {
id: applyGammastepRun
}

Process {
id: applyNotifyRun
}

Connections {
target: applyGammastepKill
function onExited() {
applyGammastepRun.command = ["gammastep", "-O", backlightModule.targetTemp.toString()];
applyGammastepRun.running = true;
applyNotifyRun.command = ["notify-send", "-u", "low", "Gammastep", `Temperatura ajustada para ${backlightModule.targetTemp}K`, "-i", "display"];
applyNotifyRun.running = true;
}
}

Process {
id: errorNotifyRun
command: ["notify-send", "-u", "critical", "Gammastep", "Valor inválido. Insira um número entre 1000 e 25000.", "-i", "dialog-warning"]
}

Timer {
id: promptDelayTimer
interval: 150
repeat: false

onTriggered: {
if (!backlightModule.textPrompt) return;

backlightModule.textPrompt.openPrompt("Temperatura (1000 a 25000):", backlightModule.parentWindow, false, (input) => {
let trimmed = input.trim();

if (/^\d+$/.test(trimmed)) {
let temp = parseInt(trimmed, 10);

if (temp >= 1000 && temp <= 25000) {
backlightModule.applyTemperature(temp);
backlightModule.textPrompt.closePrompt();
return;
}
}

errorNotifyRun.running = true;
backlightModule.textPrompt.showError("Tente novamente:");
}
);
}
}

function applyTemperature(temp) {
backlightModule.targetTemp = temp;
applyGammastepKill.running = true;
}

function generateMenuModel(isRunning) {
let menuModel = [];

if (isRunning) {
menuModel.push({ text: "Desativar Filtro", onTrigger: () => {
gammastepKill.running = true;
}});
}
else {
menuModel.push({ text: "Ativar Filtro (2500K)", onTrigger: () => {
backlightModule.applyTemperature(2500);
}});
}

menuModel.push({ type: "separator" });

menuModel.push({ text: "Definir Temperatura", preventClose: true, onTrigger: () => {
if (backlightModule.globalMenu) backlightModule.globalMenu.close(); promptDelayTimer.start();
}});

return menuModel;
}

function updateMenu(isRunning) {
if (!backlightModule.globalMenu) return;

let modelData = backlightModule.generateMenuModel(isRunning);

backlightModule.globalMenu.showSearchInput = false;
backlightModule.globalMenu.openMenu(backlightModule.parentWindow, backlightModule, modelData);
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onPressed: mouse => {
let menu = backlightModule.globalMenu;

mouse.accepted = true;

if (menu && !menu.shouldOpenFor(backlightModule)) return;

if (mouse.button === Qt.LeftButton) {
checkGammastep.running = true;
} else if (mouse.button === Qt.RightButton) {
gammastepToggleCheck.running = true;
}
}

onWheel: wheel => {
let menu = backlightModule.globalMenu;

if (menu && menu.visible && menu._currentAnchorItem === backlightModule) menu.close();
if (changeBrightness.running) return;

if (wheel.angleDelta.y > 0) {
changeBrightness.command = ["brightnessctl", "set", "+1%"];
} else {
changeBrightness.command = ["brightnessctl", "set", "1%-"];
}
changeBrightness.running = true;
}
}

Row {
id: backlightRow
anchors.verticalCenter: parent.verticalCenter
Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.backlightBrightnessColor
text: `BL: ${backlightModule.brightnessPercent}%`
}
}
}
