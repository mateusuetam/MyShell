pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Quickshell
import Qt.labs.folderlistmodel
import "../core"

Item {
id: startModule

required property var globalMenu
required property var parentWindow

implicitWidth: startRow.implicitWidth
implicitHeight: startModule.parentWindow ? startModule.parentWindow.barHeight : 30

component WallpaperDelegate: QtObject {
required property var model
readonly property string name: model.fileName
readonly property url urlPath: model.fileUrl
}

FolderListModel {
id: folderModel
folder: "file://" + Quickshell.env("HOME") + "/Imagens"
nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
showDirs: false
showDotAndDotDot: false
showOnlyReadable: true
}

Instantiator {
id: fileInstantiator
model: folderModel
delegate: WallpaperDelegate {}
onObjectAdded: rebuildDebounce.restart()
onObjectRemoved: rebuildDebounce.restart()
}

Timer {
id: rebuildDebounce
interval: 32
repeat: false
onTriggered: startModule.rebuildWallpaperMenu()
}

property var wallpaperMenuStructure: []

function rebuildWallpaperMenu() {
let list = [
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.popMenu();
}
}
},
{ type: "separator" }
];

for (var i = 0; i < fileInstantiator.count; i++) {
const obj = fileInstantiator.objectAt(i) as WallpaperDelegate;
if (!obj) continue;

list.push({
type: "action",
text: obj.name,
enabled: true,
preventClose: false,
actionType: "change_wallpaper",
actionData: obj.urlPath
});
}
startModule.wallpaperMenuStructure = list;
}

function getThemeMenuStructure() {
let list = [
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.popMenu();
}
}
},
{ type: "separator" }
];

if (Array.isArray(ThemeEngine.menuStructure)) {
return list.concat(ThemeEngine.menuStructure);
}
return list;
}

readonly property var customizationsMenuModel: [
{
type: "action",
text: "< Menu de Apps",
preventClose: true,
__internalBackItem: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = true;
startModule.globalMenu.popMenu();
}
}
},
{ type: "separator" },
{
type: "action",
text: "Trocar Wallpaper >",
preventClose: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(
startModule.wallpaperMenuStructure,
"wallpapers",
() => startModule.wallpaperMenuStructure
);
}
}
},
{
type: "action",
text: "Trocar Tema >",
preventClose: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(
startModule.getThemeMenuStructure(),
"themes"
);
}
}
}
]

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
onTrigger: () => Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"])
},
{
type: "action",
text: "Bloquear",
onTrigger: () => Quickshell.execDetached(["quickshell", "ipc", "call", "lock_manager", "lock"])
},
{ type: "separator" },
{
type: "action",
text: "Suspender",
onTrigger: () => Quickshell.execDetached(["systemctl", "suspend"])
},
{
type: "action",
text: "Reiniciar",
onTrigger: () => Quickshell.execDetached(["reboot"])
},
{
type: "action",
text: "Desligar",
onTrigger: () => Quickshell.execDetached(["shutdown", "-h", "0"])
}
]

Instantiator {
id: appsInstantiator
model: DesktopEntries.applications
delegate: QtObject {
id: appDelegate
required property var modelData
readonly property string appName: modelData ? (modelData.name || "") : ""
readonly property bool appNoDisplay: modelData ? (modelData.noDisplay || false) : false

function launch() {
if (modelData && modelData.command && modelData.command.length > 0) {
Quickshell.execDetached({
command: modelData.command,
workingDirectory: modelData.workingDirectory || ""
});
}
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
text: "Customizações >",
preventClose: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(
startModule.customizationsMenuModel,
"customizations"
);
}
}
});

processedModel.push({
type: "action",
text: "Menu de Sessão >",
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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
}
Text { font: prefixText.font; color: ThemeRegistry.sLabelColor; text: "{ S" }
Text { font: prefixText.font; color: ThemeRegistry.t1LabelColor; text: "T" }
Text { font: prefixText.font; color: ThemeRegistry.aLabelColor; text: "A" }
Text { font: prefixText.font; color: ThemeRegistry.rLabelColor; text: "R" }
Text { font: prefixText.font; color: ThemeRegistry.t2LabelColor; text: "T }" }
}
}
