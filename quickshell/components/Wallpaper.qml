pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import QtCore
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland

PanelWindow {
id: wallpaperWindow

property url wallpaperPath: wallpaperSettings.savedPath
property var menuStructure: []

readonly property size maxSourceSize: Qt.size(Math.min(wallpaperWindow.width, 1920), Math.min(wallpaperWindow.height, 1080))

Settings {
id: wallpaperSettings
location: `file://${Quickshell.env("HOME")}/.local/share/MyShell/wallpaper.conf`
category: "Wallpaper"
property url savedPath: ""
}

FolderListModel {
id: folderModel
folder: `file://${Quickshell.env("HOME")}/Imagens`
nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
showDirs: false
showDotAndDotDot: false
showOnlyReadable: true
sortField: FolderListModel.Unsorted
onCountChanged: rebuildDebounce.restart()
}

Timer {
id: rebuildDebounce
interval: 250
repeat: false
onTriggered: wallpaperWindow.rebuildMenu()
}

function rebuildMenu() {
const count = folderModel.count;
const maxItems = Math.min(count, 200);
let list = new Array(maxItems);

for (let i = 0; i < maxItems; i++) {
list[i] = {
type: "action",
text: folderModel.get(i, "fileName"),
path: folderModel.get(i, "fileUrl"),
preventClose: false
};
}

wallpaperWindow.menuStructure = list;
}

function requestWallpaperChange(path) {
wallpaperSettings.savedPath = path;
}

WlrLayershell.layer: WlrLayer.Background
WlrLayershell.namespace: "wallpaper"

anchors {
top: true
right: true
bottom: true
left: true
}

color: "#000000"
exclusionMode: ExclusionMode.Ignore

property int activeImage: 1
property url nextWallpaper: wallpaperPath

Timer {
id: unloadTimer
interval: 650
repeat: false
onTriggered: {
if (wallpaperWindow.activeImage === 1) {
img2.source = "";
} else {
img1.source = "";
}
}
}

onWallpaperPathChanged: {
nextWallpaper = wallpaperPath;

if (activeImage === 1) {
if (img2.source === nextWallpaper && img2.status === Image.Ready) {
activeImage = 2;
unloadTimer.restart();
} else {
img2.source = nextWallpaper;
}
} else {
if (img1.source === nextWallpaper && img1.status === Image.Ready) {
activeImage = 1;
unloadTimer.restart();
} else {
img1.source = nextWallpaper;
}
}
}

Item {
anchors.fill: parent

Image {
id: img1
anchors.fill: parent
sourceSize: wallpaperWindow.maxSourceSize
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: false

z: wallpaperWindow.activeImage === 1 ? 1 : 0
opacity: wallpaperWindow.activeImage === 1 ? 1.0 : 0.0

Behavior on opacity {
NumberAnimation {
duration: 600
easing.type: Easing.InOutQuad
}
}

onStatusChanged: {
if (status === Image.Ready &&
source === wallpaperWindow.nextWallpaper &&
wallpaperWindow.activeImage !== 1) {
wallpaperWindow.activeImage = 1;
unloadTimer.restart();
}
}
}

Image {
id: img2
anchors.fill: parent
sourceSize: wallpaperWindow.maxSourceSize
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: false

z: wallpaperWindow.activeImage === 2 ? 1 : 0
opacity: wallpaperWindow.activeImage === 2 ? 1.0 : 0.0

Behavior on opacity {
NumberAnimation {
duration: 600
easing.type: Easing.InOutQuad
}
}

onStatusChanged: {
if (status === Image.Ready &&
source === wallpaperWindow.nextWallpaper &&
wallpaperWindow.activeImage !== 2) {
wallpaperWindow.activeImage = 2;
unloadTimer.restart();
}
}
}
}
}
