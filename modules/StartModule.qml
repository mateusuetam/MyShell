pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "../components/themeengine"

Item {
id: startModule

required property var globalMenu
required property var parentWindow

readonly property color sLabelColor: ColorRegistry.sLabelColor
readonly property color t1LabelColor: ColorRegistry.t1LabelColor
readonly property color aLabelColor: ColorRegistry.aLabelColor
readonly property color rLabelColor: ColorRegistry.rLabelColor
readonly property color t2LabelColor: ColorRegistry.t2LabelColor
readonly property color separatorColor: ColorRegistry.startSeparatorColor
readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
readonly property int labelFontSize: TypographyRegistry.appliedFontSize

implicitWidth: startRow.implicitWidth
implicitHeight: startModule.parentWindow ? startModule.parentWindow.barHeight : 30

Process { id: cmdSair; command: ["niri", "msg", "action", "quit", "--skip-confirmation"] }
Process { id: cmdBloquear; command: ["quickshell", "ipc", "call", "lock_manager", "lock"] }
Process { id: cmdSuspender; command: ["systemctl", "suspend"] }
Process { id: cmdReiniciar; command: ["reboot"] }
Process { id: cmdDesligar; command: ["shutdown", "-h", "0"] }

readonly property var powerMenuModel: [
{
type: "action",
text: "< Menu de Apps",
onTrigger: () => startModule.openAppMenu()
},
{ type: "separator" },
{
type: "action",
text: "Sair",
onTrigger: () => cmdSair.startDetached()
},
{
type: "action",
text: "Bloquear",
onTrigger: () => cmdBloquear.startDetached()
},
{ type: "separator" },
{
type: "action",
text: "Suspender",
onTrigger: () => cmdSuspender.startDetached()
},
{
type: "action",
text: "Reiniciar",
onTrigger: () => cmdReiniciar.startDetached()
},
{
type: "action",
text: "Desligar",
onTrigger: () => cmdDesligar.startDetached()
}
]

Instantiator {
id: appsInstantiator
model: DesktopEntries.applications
delegate: QtObject {
required property var modelData
readonly property string appName: modelData ? (modelData.name || "") : ""
readonly property bool appNoDisplay: modelData ? (modelData.noDisplay || false) : false

function launch() {
if (modelData && typeof modelData.execute === "function")
modelData.execute();
}
}
}

function generateAppList() {
let processedModel = [];
let totalApps = appsInstantiator.count;

for (let i = 0; i < totalApps; i++) {
let item = appsInstantiator.objectAt(i);
if (!item || item.appNoDisplay || item.appName === "")
continue;

processedModel.push({
type: "action",
text: item.appName,
onTrigger: () => {
if (item && typeof item.launch === "function")
item.launch();
}
});
}

processedModel.sort((a, b) => a.text.localeCompare(b.text));

processedModel.push({ type: "separator" });
processedModel.push({
type: "action",
text: "< Menu de Sessão",
onTrigger: () => startModule.openSessionMenu()
});

return processedModel;
}

function openAppMenu() {
let appModel = generateAppList();
if (appModel.length > 0 && startModule.globalMenu) {
startModule.globalMenu.showSearchInput = true;
startModule.globalMenu.openMenu(startModule.parentWindow, startModule, appModel);
}
}

function openSessionMenu() {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.openMenu(startModule.parentWindow, startModule, startModule.powerMenuModel);
}
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton
onPressed: mouse => {
let menu = startModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
startModule.openAppMenu();
}
}

Row {
id: startRow
anchors.verticalCenter: parent.verticalCenter
Text {
id: prefixText
font.family: startModule.labelFontFamily
font.pixelSize: startModule.labelFontSize
color: startModule.separatorColor
text: "["
}
Text {
font: prefixText.font
color: startModule.sLabelColor
text: "S"
}
Text {
font: prefixText.font
color: startModule.t1LabelColor
text: "T"
}
Text {
font: prefixText.font
color: startModule.aLabelColor
text: "A"
}
Text {
font: prefixText.font
color: startModule.rLabelColor
text: "R"
}
Text {
font: prefixText.font
color: startModule.t2LabelColor
text: "T"
}
Text {
font: prefixText.font
color: prefixText.color
text: "]"
}
}
}
