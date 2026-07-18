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

property alias wallpaperSettings: wallpaperSettings

readonly property url currentWallpaperPath: wallpaperWindow.wallpaperSettings.savedPath

WlrLayershell.layer: WlrLayer.Background
WlrLayershell.namespace: "wallpaper"

anchors {
top: true
right: true
bottom: true
left: true
}
exclusionMode: ExclusionMode.Ignore
focusable: false

Settings {
id: wallpaperSettings
location: "file://" + Quickshell.env("HOME") + "/.wallpaper.conf"
category: "Wallpaper"
property url savedPath: ""
}

property bool useA: true

property bool isFullyLoaded: false

Component.onCompleted: {
if (wallpaperWindow.wallpaperSettings.savedPath.toString() !== "") {
imgA.source = wallpaperWindow.wallpaperSettings.savedPath;
}
wallpaperWindow.isFullyLoaded = true;
}

Connections {
target: wallpaperWindow.wallpaperSettings
function onSavedPathChanged() {
var newPath = wallpaperWindow.wallpaperSettings.savedPath;
if (newPath.toString() === "") return;

if (wallpaperWindow.useA) {
if (imgB.source.toString() === newPath.toString() && imgB.status === Image.Ready) {
wallpaperWindow.useA = false;
} else {
imgB.source = newPath;
}
} else {
if (imgA.source.toString() === newPath.toString() && imgA.status === Image.Ready) {
wallpaperWindow.useA = true;
} else {
imgA.source = newPath;
}
}
}
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
case "change_wallpaper":
wallpaperWindow.wallpaperSettings.savedPath = data;
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
onTrigger: () => {
if (wallpaperWindow.globalMenu) {
wallpaperWindow.globalMenu.pushMenu(
wallpaperWindow.subMenuStructure,
"wallpapers",
() => wallpaperWindow.subMenuStructure
);
}
}
}
]

Rectangle {
anchors.fill: parent
color: "black"
}

Image {
id: imgA
sourceSize: Qt.size(wallpaperWindow.width, wallpaperWindow.height)
anchors.fill: parent
fillMode: Image.PreserveAspectCrop

asynchronous: wallpaperWindow.isFullyLoaded
cache: true

visible: imgA.source !== "" || imgA.opacity > 0
opacity: (wallpaperWindow.useA && imgA.status === Image.Ready) ? 1.0 : 0.0

Behavior on opacity {
NumberAnimation {
duration: 100;
easing.type: Easing.OutQuad

onFinished: {
if (!wallpaperWindow.useA && imgA.opacity === 0) {
imgA.source = ""
}
}
}
}

onStatusChanged: {
if (imgA.status === Image.Ready && !wallpaperWindow.useA) {
wallpaperWindow.useA = true;
}
}
}

Image {
id: imgB
sourceSize: Qt.size(wallpaperWindow.width, wallpaperWindow.height)
anchors.fill: parent
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: true

visible: imgB.source !== "" || imgB.opacity > 0
opacity: (!wallpaperWindow.useA && imgB.status === Image.Ready) ? 1.0 : 0.0

Behavior on opacity {
NumberAnimation {
duration: 100;
easing.type: Easing.OutQuad

onFinished: {
if (wallpaperWindow.useA && imgB.opacity === 0) {
imgB.source = ""
}
}
}
}

onStatusChanged: {
if (imgB.status === Image.Ready && wallpaperWindow.useA) {
wallpaperWindow.useA = false;
}
}
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
