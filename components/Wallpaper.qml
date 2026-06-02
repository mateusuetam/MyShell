import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wallpaperWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    focusable: false

    Component.onCompleted: {
        if (this.WlrLayershell !== null) {
            this.WlrLayershell.layer = WlrLayer.Background;
            this.WlrLayershell.namespace = "wallpaper";
        }
    }

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/Imagens/afina.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
}
