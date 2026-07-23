pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
id: wallpaperWindow

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

Image {
id: img
source: wallpaperWindow.wallpaperPath
sourceSize: wallpaperWindow.wallpaperSize
anchors.fill: parent
fillMode: Image.PreserveAspectCrop
asynchronous: true
cache: false
}
}
