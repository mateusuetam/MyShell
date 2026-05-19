import QtQuick
import Quickshell.Wayland

Item {
    id: idleModule

    readonly property string textColor: "#ebdbb2"
    readonly property string idlingColor: "#a89984"
    readonly property string watchingColor: "#8ec07c"
    readonly property bool isActive: inhibitor.enabled
    property var parentWindow: null

    IdleInhibitor {
        id: inhibitor
        window: idleModule.parentWindow
        enabled: false
    }

    implicitWidth: idleText.implicitWidth
    implicitHeight: 30

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            inhibitor.enabled = !inhibitor.enabled;
        }
    }

    Text {
        id: idleText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        color: idleModule.isActive ? idleModule.watchingColor : idleModule.idlingColor
        text: {
            var prefix = `<span style="color: ${idleModule.textColor};">idle:</span>`;
            return idleModule.isActive ? `${prefix} watching` : `${prefix} idling`;
        }
    }
}
