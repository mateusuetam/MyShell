import QtQuick
import Quickshell.Io
import "../components/themeengine"

Item {
id: backlightModule

required property var globalMenu
required property var parentWindow

readonly property color labelColor: ThemeRegistry.backlightLabelColor
readonly property color brightnessColor: ThemeRegistry.backlightBrightnessColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

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
if (!isNaN(val)) {
backlightModule.brightnessPercent = val;
}
}
}
Component.onCompleted: readBrightness.running = true
}

Process { id: changeBrightness }
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
id: gammastepKill
command: ["pkill", "-f", "gammastep"]
}

Process {
id: gammastepStart
command: ["sh", "-c", "notify-send -u low Gammastep 'Temperatura ajustada para 2500K' && gammastep -O 2500"]
}

Process {
id: gammastepToggleCheck
command: ["pgrep", "-f", "gammastep"]
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
Connections {
target: applyGammastepKill
function onExited() {
applyGammastepRun.command = ["gammastep", "-O", backlightModule.targetTemp.toString()];
applyGammastepRun.running = true;
applyNotifyRun.command = ["notify-send", "-u", "low", "Gammastep", `Temperatura ajustada para ${backlightModule.targetTemp}K`, "-i", "display"];
applyNotifyRun.running = true;
}
}

Process { id: applyGammastepRun }
Process { id: applyNotifyRun }

function applyTemperature(temp) {
backlightModule.targetTemp = temp;
applyGammastepKill.running = true;
}

function generateMenuModel(isRunning) {
let menuModel = [];

if (isRunning) {
menuModel.push({
text: "Desativar Filtro",
onTrigger: () => {
gammastepKill.running = true;
}
});
} else {
menuModel.push({
text: "Ativar Filtro (2500K)",
onTrigger: () => {
backlightModule.applyTemperature(2500);
}
});
}
menuModel.push({ type: "separator" });

const tempPresets = [2000, 2500, 3000, 3500, 4000, 4500, 5000];
for (let i = 0; i < tempPresets.length; i++) {
let temp = tempPresets[i];
menuModel.push({
text: `Temperatura: ${temp}K`,
onTrigger: () => {
backlightModule.applyTemperature(temp);
}
});
}

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
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
checkGammastep.running = true;
} else if (mouse.button === Qt.RightButton) {
gammastepToggleCheck.running = true;
}
}
onWheel: wheel => {
let menu = backlightModule.globalMenu;
if (menu) {
menu.close();
}
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
id: backlightPrefix
font.family: backlightModule.labelFontFamily
font.pixelSize: backlightModule.labelFontSize
color: backlightModule.labelColor
text: "BL: "
}
Text {
font: backlightPrefix.font
color: backlightModule.brightnessColor
text: `${backlightModule.brightnessPercent}%`
}
}
}
