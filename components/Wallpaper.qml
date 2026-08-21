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
onCountChanged: rebuildDebounce.restart()
}

Timer {
id: rebuildDebounce
interval: 100
repeat: false
onTriggered: wallpaperWindow.rebuildMenu()
}

function rebuildMenu() {
let list = [];
const maxItems = Math.min(folderModel.count, 500);

for (let i = 0; i < maxItems; i++) {
const path = folderModel.get(i, "fileUrl");
const name = folderModel.get(i, "fileName");

list.push({
type: "action",
text: name,
path: path,
preventClose: false
});
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

onWallpaperPathChanged: {
nextWallpaper = wallpaperPath;

if (activeImage === 1) {
if (String(img2.source) === String(nextWallpaper) && img2.status === Image.Ready) {
activeImage = 2;
} else {
img2.source = nextWallpaper;
}
} else {
if (String(img1.source) === String(nextWallpaper) && img1.status === Image.Ready) {
activeImage = 1;
} else {
img1.source = nextWallpaper;
}
}
}

Component.onCompleted: {
img1.source = wallpaperPath;
}

Item {
anchors.fill: parent

Image {
id: img1
anchors.fill: parent
sourceSize: Qt.size(width, height)
fillMode: Image.PreserveAspectCrop
asynchronous: true

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
String(source) === String(wallpaperWindow.nextWallpaper) &&
wallpaperWindow.activeImage !== 1) {
wallpaperWindow.activeImage = 1;
}
}
}

Image {
id: img2
anchors.fill: parent
sourceSize: Qt.size(width, height)
fillMode: Image.PreserveAspectCrop
asynchronous: true

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
String(source) === String(wallpaperWindow.nextWallpaper) &&
wallpaperWindow.activeImage !== 2) {
wallpaperWindow.activeImage = 2;
}
}
}
}
}
