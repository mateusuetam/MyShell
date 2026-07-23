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

implicitWidth: startRow.implicitWidth
implicitHeight: startModule.parentWindow ? startModule.parentWindow.barHeight : 30

component AppDelegate: QtObject {
required property DesktopEntry modelData
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
if (!startModule.globalMenu)
return;

const wallpaperMenuItems = WallpaperEngine.menuStructure.map(item => ({
type: item.type,
text: item.text,
preventClose: item.preventClose,
onTrigger: () => WallpaperEngine.requestWallpaperChange(item.path)
}));

startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(
[
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => startModule.globalMenu?.popMenu()
},
{ type: "separator" }
].concat(wallpaperMenuItems),
"wallpapers"
);
}
},
{
type: "action",
text: "Trocar Tema >",
preventClose: true,
onTrigger: () => {
if (!startModule.globalMenu)
return;
startModule.globalMenu.showSearchInput = false;
startModule.globalMenu.pushMenu(
[
{
type: "action",
text: "< Customizações",
preventClose: true,
__internalBackItem: true,
onTrigger: () => startModule.globalMenu?.popMenu()
},
{ type: "separator" }
].concat(ThemeEngine.menuStructure),
"themes"
);
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
Text {
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
color: ThemeRegistry.startLabelColor;
text: "{ START }"
}
}
}
