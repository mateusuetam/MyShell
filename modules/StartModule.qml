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

readonly property font startFont: Qt.font({
family: ThemeRegistry.appliedFontFamily,
pixelSize: ThemeRegistry.appliedFontSize
})

property var cachedAppMenu: []
property var cachedThemeMenu: []
property var wallpaperMenuStructure: []

implicitWidth: startRow.implicitWidth
implicitHeight: startModule.parentWindow ? startModule.parentWindow.barHeight : 30

component AppDelegate: QtObject {
required property DesktopEntry modelData
}

FolderListModel {
id: folderModel
folder: `file://${Quickshell.env("HOME")}/Imagens`
nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
showDirs: false
showDotAndDotDot: false
showOnlyReadable: true
onCountChanged: rebuildDebounce.restart()
}

Timer {
id: rebuildDebounce
interval: 100
repeat: false
onTriggered: startModule.rebuildWallpaperMenu()
}

function rebuildWallpaperMenu() {
let list = [
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => startModule.globalMenu?.popMenu()
},
{ type: "separator" }
];

for (let i = 0; i < folderModel.count; i++) {
list.push({
type: "action",
text: folderModel.get(i, "fileName"),
preventClose: false,
actionType: "change_wallpaper",
actionData: folderModel.get(i, "fileUrl")
});
}
startModule.wallpaperMenuStructure = list;
}

function rebuildThemeMenu() {
cachedThemeMenu = [
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => startModule.globalMenu?.popMenu()
},
{ type: "separator" }
];

if (Array.isArray(ThemeEngine.menuStructure)) {
cachedThemeMenu = cachedThemeMenu.concat(ThemeEngine.menuStructure);
}
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
if (cachedThemeMenu.length === 0) rebuildThemeMenu();
startModule.globalMenu.pushMenu(cachedThemeMenu, "themes");
}
}
}
]

readonly property var powerMenuModel: [
{ type: "action", text: "< Menu de Apps", onTrigger: () => startModule.openAppMenu() },
{ type: "separator" },
{ type: "action", text: "Sair", onTrigger: () => Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"]) },
{ type: "action", text: "Bloquear", onTrigger: () => Quickshell.execDetached(["quickshell", "ipc", "call", "lock_manager", "lock"]) },
{ type: "separator" },
{ type: "action", text: "Suspender", onTrigger: () => Quickshell.execDetached(["systemctl", "suspend"]) },
{ type: "action", text: "Reiniciar", onTrigger: () => Quickshell.execDetached(["reboot"]) },
{ type: "action", text: "Desligar", onTrigger: () => Quickshell.execDetached(["shutdown", "-h", "0"]) }
]

Instantiator {
id: appsInstantiator
model: DesktopEntries.applications

onObjectAdded: startModule.cachedAppMenu = []
onObjectRemoved: startModule.cachedAppMenu = []

delegate: AppDelegate {}
}

function rebuildAppMenu() {
let processedModel = [];
let totalApps = appsInstantiator.count;

for (let i = 0; i < totalApps; i++) {
const item = appsInstantiator.objectAt(i) as AppDelegate;
if (!item || !item.modelData) continue;

const entry = item.modelData;
if (entry.noDisplay || !entry.name) continue;

processedModel.push({
type: "action",
text: entry.name,
onTrigger: () => entry.execute()
});
}

processedModel.sort((a, b) => a.text.localeCompare(b.text));

processedModel.push(
{ type: "separator" },
{
type: "action",
text: "Customizações >",
preventClose: true,
onTrigger: () => {
if (startModule.globalMenu) {
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(startModule.customizationsMenuModel, "customizations");
}
}
},
{
type: "action",
text: "Menu de Sessão >",
onTrigger: () => startModule.openSessionMenu()
}
);

cachedAppMenu = processedModel;
}

function openAppMenu() {
if (cachedAppMenu.length === 0) rebuildAppMenu();

if (cachedAppMenu.length > 0 && startModule.globalMenu) {
startModule.globalMenu.showSearchInput = true;
startModule.globalMenu.openMenu(startModule.parentWindow, startModule, cachedAppMenu);
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
mouse.accepted = true;
startModule.globalMenu?.close();
startModule.openAppMenu();
}
}

Row {
id: startRow
anchors.verticalCenter: parent.verticalCenter
Text { font: startModule.startFont; color: ThemeRegistry.sLabelColor; text: "{ S" }
Text { font: startModule.startFont; color: ThemeRegistry.t1LabelColor; text: "T" }
Text { font: startModule.startFont; color: ThemeRegistry.aLabelColor; text: "A" }
Text { font: startModule.startFont; color: ThemeRegistry.rLabelColor; text: "R" }
Text { font: startModule.startFont; color: ThemeRegistry.t2LabelColor; text: "T }" }
}
}
