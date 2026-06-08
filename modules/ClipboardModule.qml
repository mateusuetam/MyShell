import QtQuick
import Quickshell.Io
import "../components/themeengine"

Item {
    id: clipboardModule

    required property var globalMenu
    required property var parentWindow

    readonly property color utilityColor: ColorRegistry.clipboardUtilityColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    implicitWidth: clipboardRow.implicitWidth
    implicitHeight: clipboardModule.parentWindow ? clipboardModule.parentWindow.barHeight : 30

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
        onPressed: mouse => {
            let menu = clipboardModule.globalMenu;
            if (menu) {
                menu.close();
            }
            mouse.accepted = true;
            if (mouse.button === Qt.LeftButton) {
                clipMenu.startDetached();
            } else if (mouse.button === Qt.RightButton) {
                clipWipe.startDetached();
            }
        }
    }

    Row {
        id: clipboardRow
        anchors.verticalCenter: parent.verticalCenter
        Text {
            font.family: clipboardModule.labelFontFamily
            font.pixelSize: clipboardModule.labelFontSize
            color: clipboardModule.utilityColor
            text: "clipboard"
        }
    }
}
