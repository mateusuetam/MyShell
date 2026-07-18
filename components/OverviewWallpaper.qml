pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
id: overviewWallpaperWindow

WlrLayershell.layer: WlrLayer.Background
WlrLayershell.namespace: "wallpaper-blur"

anchors {
top: true
right: true
bottom: true
left: true
}
exclusionMode: ExclusionMode.Ignore
focusable: false

property url wallpaperPath: ""

Rectangle {
anchors.fill: parent
color: "black"
}

Image {
id: bgImage

anchors {
fill: parent
margins: -100
}

source: overviewWallpaperWindow.wallpaperPath
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: true

sourceSize.width: Math.max(1, overviewWallpaperWindow.width / 4)
sourceSize.height: Math.max(1, overviewWallpaperWindow.height / 4)

visible: false
}

MultiEffect {
anchors.fill: bgImage
source: bgImage
blurEnabled: true
blurMax: 20
blur: 1.0
brightness: -0.05
}
}
