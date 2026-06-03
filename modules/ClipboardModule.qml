import QtQuick
import Quickshell.Io
import "../components/theme"

Item {
    id: clipboardModule

    implicitWidth: clipText.implicitWidth
    implicitHeight: 30

    Process {
        id: clipMenu
        command: ["sh", "-c", "cliphist list | rofi -dmenu -theme $HOME/Documentos/repos/configs/rofi/launcher.rasi | cliphist decode | wl-copy"]
    }

    Process {
        id: clipWipe
        command: ["sh", "-c", "cliphist wipe && notify-send Clipboard 'Histórico apagado!'"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                clipMenu.startDetached();
            } else if (mouse.button === Qt.RightButton) {
                clipWipe.startDetached();
            }
        }
    }

    Text {
        id: clipText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.uniqueColor
        anchors.verticalCenter: parent.verticalCenter
        text: "clipboard"
    }
}
