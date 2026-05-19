import QtQuick
import Quickshell.Io

Item {
    id: powermenuModule

    readonly property string powerColor: "#fb4934"

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
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        color: powermenuModule.powerColor
        anchors.verticalCenter: parent.verticalCenter
        text: "power"
    }
}
