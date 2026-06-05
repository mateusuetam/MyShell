pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wallpaperWindow

    property url sourcePath: "file://" + Quickshell.env("HOME") + "/Imagens/afina.png"
    readonly property int imageFillMode: Image.Center

    property var globalMenu: null

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

    WallpaperModel {
        id: backendModel

        onWallpaperSelected: fileUrl => {
            wallpaperWindow.sourcePath = fileUrl;
        }
    }

    Connections {
        target: wallpaperWindow.globalMenu

        function onItemDataActionTriggered(actionType, data) {
            if (actionType === "open_wallpaper_submenu") {
                if (wallpaperWindow.globalMenu) {
                    wallpaperWindow.globalMenu.menuModel = backendModel.subMenuStructure;
                }
            } else if (actionType === "change_wallpaper") {
                backendModel.wallpaperSelected(data);
            }
        }
    }

    readonly property var desktopMenuStructure: [
        {
            text: "Wallpaper Changer",
            icon: "",
            isSeparator: false,
            preventClose: true,
            actionType: "open_wallpaper_submenu",
            actionData: null
        }
    ]

    Image {
        anchors.fill: parent
        source: wallpaperWindow.sourcePath
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        asynchronous: true
        cache: true
    }

    MouseArea {
        id: wallpaperArea

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true
        onClicked: mouse => {
            if (!wallpaperWindow.globalMenu)
                return;
            if (mouse.button === Qt.RightButton) {
                wallpaperWindow.globalMenu.openAtPosition(wallpaperWindow, mouse.x, mouse.y, wallpaperWindow.desktopMenuStructure);
                mouse.accepted = true;
            } else if (mouse.button === Qt.LeftButton) {
                wallpaperWindow.globalMenu.visible = false;
                mouse.accepted = false;
            }
        }
    }
}