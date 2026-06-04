import QtQuick
import Quickshell.Io
import "../components/themeengine"

Item {
    id: powermenuModule

    readonly property color sessionColor: ColorRegistry.powerSessionColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    implicitWidth: powerText.implicitWidth
    implicitHeight: 30

    Process {
        id: powerCmd
        command: ["sh", "-c", "$HOME/Documentos/repos/configs/scripts/powermenu.sh"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            powerCmd.startDetached();
        }
    }

    Text {
        id: powerText

        font.family: powermenuModule.labelFontFamily
        font.pixelSize: powermenuModule.labelFontSize

        color: powermenuModule.sessionColor
        anchors.verticalCenter: parent.verticalCenter
        text: "-SESS-"
    }
}
