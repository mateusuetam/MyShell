pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import QtCore
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
id: wallpaperWindow

required property var globalMenu

property bool useA: true
property bool isFullyLoaded: false

property alias wallpaperSettings: wallpaperSettings
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

Settings {
id: wallpaperSettings
location: ConfigPaths.wallpaperConfig
category: "Wallpaper"
property url savedPath: ""
}

component FadeAnimation: NumberAnimation {
duration: 600
easing.type: Easing.InOutSine
}

Component.onCompleted: {
if (wallpaperWindow.wallpaperSettings.savedPath !== "") {
imgA.source = wallpaperWindow.wallpaperSettings.savedPath;
}
wallpaperWindow.isFullyLoaded = true;
}

Connections {
target: wallpaperWindow.wallpaperSettings
function onSavedPathChanged() {
var newPath = wallpaperWindow.wallpaperSettings.savedPath;
if (newPath === "") return;

if (wallpaperWindow.useA) {
if (imgB.source === newPath && imgB.status === Image.Ready) {
wallpaperWindow.useA = false;
} else {
imgB.source = newPath;
}
} else {
if (imgA.source === newPath && imgA.status === Image.Ready) {
wallpaperWindow.useA = true;
} else {
imgA.source = newPath;
}
}
}
}

Connections {
target: wallpaperWindow.globalMenu

function onItemDataActionTriggered(actionType, data) {
if (actionType === "change_wallpaper")
wallpaperWindow.wallpaperSettings.savedPath = data;
}
}

function shouldFadeIn(active, status, otherOpacity) {
return (active && status === Image.Ready) || (!active && otherOpacity < 1);
}

Image {
id: imgA
readonly property bool hasSource: source !== ""

sourceSize: wallpaperWindow.wallpaperSize
anchors.fill: parent
fillMode: Image.PreserveAspectCrop
asynchronous: wallpaperWindow.isFullyLoaded
visible: hasSource || opacity > 0
z: wallpaperWindow.useA ? 1 : 0

opacity: wallpaperWindow.shouldFadeIn(wallpaperWindow.useA, status, imgB.opacity) ? 1 : 0

Behavior on opacity {
FadeAnimation {
onFinished: {
if (!wallpaperWindow.useA && imgA.opacity === 0.0) {
imgA.source = "";
}
}
}
}

onStatusChanged: {
if (status === Image.Ready && !wallpaperWindow.useA && hasSource) {
wallpaperWindow.useA = true;
}
}
}

Image {
id: imgB
readonly property bool hasSource: source !== ""

sourceSize: wallpaperWindow.wallpaperSize
anchors.fill: parent
fillMode: Image.PreserveAspectCrop
asynchronous: true
visible: hasSource || opacity > 0
z: !wallpaperWindow.useA ? 1 : 0

opacity: wallpaperWindow.shouldFadeIn(!wallpaperWindow.useA, status, imgA.opacity) ? 1 : 0

Behavior on opacity {
FadeAnimation {
onFinished: {
if (wallpaperWindow.useA && imgB.opacity === 0.0) {
imgB.source = "";
}
}
}
}

onStatusChanged: {
if (status === Image.Ready && wallpaperWindow.useA && hasSource) {
wallpaperWindow.useA = false;
}
}
}
}
