import QtQuick
import Quickshell.Io
import "../components/theme"

Item {
    id: powermenuModule

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
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.warmColor
        anchors.verticalCenter: parent.verticalCenter
        text: "-SESS-"
    }
}
