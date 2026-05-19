import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: micModule

    readonly property string textColor: "#ebdbb2"
    readonly property string mutedColor: "#fe8019"
    readonly property string volumeColor: "#b8bb26"

    readonly property var micNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
    readonly property int micPercent: micNode ? Math.round(micNode.volume * 100) : 0
    readonly property bool micMuted: micNode ? micNode.muted : false

    PwObjectTracker {
        id: sourceTracker
        objects: [Pipewire.defaultAudioSource]
    }

    implicitWidth: micText.implicitWidth
    implicitHeight: 30
    visible: Pipewire.ready && Pipewire.defaultAudioSource !== null

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (micModule.micNode)
                micModule.micNode.muted = !micModule.micNode.muted;
        }

        onWheel: wheel => {
            if (!micModule.micNode)
                return;
            var step = 0.01;
            if (wheel.angleDelta.y > 0) {
                micModule.micNode.volume = Math.min(1.0, micModule.micNode.volume + step);
            } else {
                micModule.micNode.volume = Math.max(0.0, micModule.micNode.volume - step);
            }
        }
    }

    Text {
        id: micText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        color: micModule.micMuted ? micModule.mutedColor : micModule.volumeColor

        text: {
            var prefix = `<span style="color: ${micModule.textColor};">mic:</span>`;
            return micModule.micMuted ? `${prefix} muted` : `${prefix} ${micModule.micPercent}%`;
        }
    }
}
