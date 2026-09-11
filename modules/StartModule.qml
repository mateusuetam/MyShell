pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Quickshell
import "../core"

Item {
id: startModule

required property var globalMenu
required property var parentWindow

property var cachedAppMenu: []

property var wallpaperMenuStructure: []
signal wallpaperChangeRequested(string path)

implicitWidth: startRow.implicitWidth
implicitHeight: startModule.parentWindow ? startModule.parentWindow.barHeight : 30

component AppDelegate: QtObject {
required property DesktopEntry modelData
}

function createBackItem(text, restoreSearch, fixedHeader) {
return {
type: "action",
text: text,
preventClose: true,
__fixedHeader: fixedHeader === true,
onTrigger: () => {
if (!startModule.globalMenu) return;
startModule.globalMenu.showSearchInput = restoreSearch;
startModule.globalMenu.popMenu();
}
};
}

function pushSubMenu(model, tag, showSearchInput) {
if (!startModule.globalMenu) return;

startModule.globalMenu.showSearchInput = showSearchInput;
startModule.globalMenu.pushMenu(model, tag);
}

readonly property var customizationsMenuModel: [
createBackItem("< Menu de Apps", true, false),

{ type: "separator" },

{
type: "action",
text: "Trocar Wallpaper >",
preventClose: true,
onTrigger: () => {
if (!startModule.globalMenu) return;
const wallpaperMenuItems = startModule.wallpaperMenuStructure.map(item => ({
type: item.type,
text: item.text,
preventClose: true,
onTrigger: () => startModule.wallpaperChangeRequested(item.path) }));
startModule.pushSubMenu([createBackItem("< Customizações", false, true)].concat(wallpaperMenuItems), "wallpapers", false);
}
},

{
type: "action",
text: "Trocar Tema >",
preventClose: true,
onTrigger: () => {
if (!startModule.globalMenu) return;
const themeMenuItems = ThemeEngine.menuStructure.map(item => ({
type: item.type,
text: item.text,
preventClose: true,
onTrigger: item.onTrigger }));
startModule.pushSubMenu([createBackItem("< Customizações", false, true)].concat(themeMenuItems), "themes", false);
}
}
]

readonly property var powerMenuModel: [
createBackItem("< Menu de Apps", true, false),
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
{
type: "action",
text: "Customizações >",
preventClose: true,
__fixedFooter: true,
onTrigger: () => {
startModule.pushSubMenu(startModule.customizationsMenuModel, "customizations", false);
}
},

{
type: "action",
text: "Menu de Sessão >",
preventClose: true,
__fixedFooter: true,
onTrigger: () => {
startModule.pushSubMenu(startModule.powerMenuModel, "session", false);
}
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

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton

onPressed: mouse => {
let menu = startModule.globalMenu;
mouse.accepted = true;

if (menu && !menu.shouldOpenFor(startModule)) return;

startModule.openAppMenu();
}
}

Row {
id: startRow

anchors.verticalCenter: parent.verticalCenter

Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.startLabelColor
text: "START"
}
}
}
