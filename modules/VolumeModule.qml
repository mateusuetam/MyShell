import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: volumeModule

    readonly property string textColor: "#ebdbb2"
    readonly property string mutedColor: "#fe8019"
    readonly property string volumeColor: "#b8bb26"

    readonly property var audioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property int volPercent: audioNode ? Math.round(audioNode.volume * 100) : 0
    readonly property bool volMuted: audioNode ? audioNode.muted : false

    PwObjectTracker {
        id: sinkTracker
        objects: [Pipewire.defaultAudioSink]
    }

    implicitWidth: volText.implicitWidth
    implicitHeight: 30
    visible: Pipewire.ready && Pipewire.defaultAudioSink !== null

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (volumeModule.audioNode)
                volumeModule.audioNode.muted = !volumeModule.audioNode.muted;
        }

        onWheel: wheel => {
            if (!volumeModule.audioNode)
                return;
            var step = 0.01;
            if (wheel.angleDelta.y > 0) {
                volumeModule.audioNode.volume = Math.min(1.0, volumeModule.audioNode.volume + step);
            } else {
                volumeModule.audioNode.volume = Math.max(0.0, volumeModule.audioNode.volume - step);
            }
        }
    }

    Text {
        id: volText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        color: volumeModule.volMuted ? volumeModule.mutedColor : volumeModule.volumeColor

        text: {
            var prefix = `<span style="color: ${volumeModule.textColor};">vol:</span>`;
            return volumeModule.volMuted ? `${prefix} muted` : `${prefix} ${volumeModule.volPercent}%`;
        }
    }
}
