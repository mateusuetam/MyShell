pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import QtCore
import Quickshell
import Quickshell.Wayland
import Qt.labs.folderlistmodel

PanelWindow {
id: wallpaperWindow

required property var globalMenu

property var subMenuStructure: []

WlrLayershell.layer: WlrLayer.Background
WlrLayershell.namespace: "wallpaper"

anchors {
top: true
right: true
bottom: true
left: true
}
exclusiveZone: -1
focusable: false

Settings {
id: wallpaperSettings
location: "file://" + Quickshell.env("HOME") + "/.wallpaper.conf"
category: "Wallpaper"
property url savedPath: ""
}

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
onTriggered: wallpaperWindow.rebuildMenu()
}

function rebuildMenu() {
let list = [];
for (var i = 0; i < fileInstantiator.count; i++) {
const obj = fileInstantiator.objectAt(i) as WallpaperDelegate;
if (!obj) continue;

list.push({
type: "action",
text: obj.name,
icon: "",
enabled: true,
preventClose: false,
actionType: "change_wallpaper",
actionData: obj.urlPath
});
}
wallpaperWindow.subMenuStructure = list;
}

Connections {
target: wallpaperWindow.globalMenu
function onItemDataActionTriggered(actionType, data) {
switch (actionType) {
case "open_wallpaper_submenu":
wallpaperWindow.globalMenu.menuModel = wallpaperWindow.subMenuStructure;
break;
case "change_wallpaper":
wallpaperSettings.savedPath = data;
break;
}
}

function onVisibleChanged() {
if (wallpaperWindow.globalMenu && !wallpaperWindow.globalMenu.visible) {
if (!wallpaperWindow.globalMenu._isInternalReset) {
wallpaperWindow.focusable = false;
}
}
}
}

readonly property var desktopMenuStructure: [
{
type: "action",
text: "Trocar Wallpaper",
icon: "",
preventClose: true,
actionType: "open_wallpaper_submenu",
actionData: null
}
]

Rectangle {
anchors.fill: parent
color: "black"
}

Image {
anchors.fill: parent
source: wallpaperSettings.savedPath
fillMode: Image.PreserveAspectCrop
horizontalAlignment: Image.AlignHCenter
verticalAlignment: Image.AlignVCenter
asynchronous: true
cache: true
}

MouseArea {
anchors.fill: parent
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
let menu = wallpaperWindow.globalMenu;
if (!menu) return;

mouse.accepted = true;
if (mouse.button === Qt.RightButton) {
wallpaperWindow.focusable = true;
menu.showSearchInput = false;
menu.openAtPosition(wallpaperWindow, mouse.x, mouse.y, wallpaperWindow.desktopMenuStructure);
} else if (mouse.button === Qt.LeftButton) {
menu.close();
}
}
}
}
