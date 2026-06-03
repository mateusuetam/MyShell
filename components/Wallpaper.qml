import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wallpaperWindow

    readonly property url wallpaperPath: "file://" + Quickshell.env("HOME") + "/Imagens/afina.png"

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    exclusiveZone: 0
    focusable: false

    Image {
        anchors.fill: parent
        source: wallpaperWindow.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }
}
