import QtQuick
import Quickshell.Wayland
import "../components/themeengine"

Item {
    id: idleModule

    readonly property color activatedColor: ColorRegistry.idleActivatedColor
    readonly property color deactivatedColor: ColorRegistry.idleDeactivatedColor
    readonly property color labelColor: ColorRegistry.idleLabelColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

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

        font.family: idleModule.labelFontFamily
        font.pixelSize: idleModule.labelFontSize
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText

        color: idleModule.isActive ? idleModule.activatedColor : idleModule.deactivatedColor

        text: {
            var prefix = `<span style="color: ${idleModule.labelColor};">idle:</span>`;
            return idleModule.isActive ? `${prefix} watching` : `${prefix} idling`;
        }
    }
}
