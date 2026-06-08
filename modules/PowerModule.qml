import QtQuick
import Quickshell.Io
import "../components/themeengine"

Item {
    id: powermenuModule

    required property var globalMenu
    required property var parentWindow

    readonly property color sessionColor: ColorRegistry.powerSessionColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    implicitWidth: powerRow.implicitWidth
    implicitHeight: powermenuModule.parentWindow ? powermenuModule.parentWindow.barHeight : 30

    Process {
        id: powerCmd
        command: ["sh", "-c", "$HOME/Documentos/repos/configs/scripts/powermenu.sh"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onPressed: mouse => {
            let menu = powermenuModule.globalMenu;
            if (menu) {
                menu.close();
            }
            mouse.accepted = true;
            if (mouse.button === Qt.LeftButton) {
                powerCmd.startDetached();
            }
        }
    }

    Row {
        id: powerRow
        anchors.verticalCenter: parent.verticalCenter
        Text {
            font.family: powermenuModule.labelFontFamily
            font.pixelSize: powermenuModule.labelFontSize
            color: powermenuModule.sessionColor
            text: "-SESS-"
        }
    }
}
