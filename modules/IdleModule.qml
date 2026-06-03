import QtQuick
import Quickshell.Wayland
import "../components/theme"

Item {
    id: idleModule

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
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        color: idleModule.isActive ? Theme.activeColor : Theme.unfocusedColor
        text: {
            var prefix = `<span style="color: ${Theme.textColor};">idle:</span>`;
            return idleModule.isActive ? `${prefix} watching` : `${prefix} idling`;
        }
    }
}
