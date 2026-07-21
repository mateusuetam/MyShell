pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland

PanelWindow {
id: wallpaperWindow

property bool useA: true
property url wallpaperPath: ""
readonly property size wallpaperSize: Qt.size(width, height)

WlrLayershell.layer: WlrLayer.Background
WlrLayershell.namespace: "wallpaper"

anchors {
top: true
right: true
bottom: true
left: true
}
exclusionMode: ExclusionMode.Ignore
color: "transparent"

component FadeAnimation: NumberAnimation {
duration: 600
easing.type: Easing.InOutSine
}

onWallpaperPathChanged: applyWallpaper(wallpaperPath)

function applyWallpaper(path) {
if (!path || path === "")
return;

const activeImg = useA ? imgA : imgB;
const targetImg = useA ? imgB : imgA;

if (activeImg.source === path)
return;

targetImg.source = path;

if (targetImg.status === Image.Ready) {
useA = !useA;
}
}

component WallpaperImage : Image {
sourceSize: wallpaperWindow.wallpaperSize
anchors.fill: parent
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: false
}

WallpaperImage {
id: imgA

z: wallpaperWindow.useA ? 1 : 0
opacity: wallpaperWindow.useA ? 1 : 0

Behavior on opacity {
FadeAnimation {
onFinished: {
if (!wallpaperWindow.useA)
imgA.source = "";
}
}
}

onStatusChanged: {
if (status === Image.Ready && !wallpaperWindow.useA && source !== "") {
wallpaperWindow.useA = true;
}
}
}

WallpaperImage {
id: imgB

z: wallpaperWindow.useA ? 0 : 1
opacity: wallpaperWindow.useA ? 0 : 1

Behavior on opacity {
FadeAnimation {
onFinished: {
if (wallpaperWindow.useA)
imgB.source = "";
}
}
}

onStatusChanged: {
if (status === Image.Ready && wallpaperWindow.useA && source !== "") {
wallpaperWindow.useA = false;
}
}
}
}
