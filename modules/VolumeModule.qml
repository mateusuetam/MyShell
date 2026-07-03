import QtQuick
import Quickshell.Services.Pipewire
import "../core"

Item {
id: volumeModule

required property var globalMenu
required property var parentWindow

readonly property color mutedColor: ThemeRegistry.volumeMutedColor
readonly property color activeColor: ThemeRegistry.volumeActiveColor
readonly property color labelColor: ThemeRegistry.volumeLabelColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

readonly property var audioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
readonly property int volPercent: audioNode ? Math.round(audioNode.volume * 100) : 0
readonly property bool volMuted: audioNode ? audioNode.muted : false

implicitWidth: volRow.implicitWidth
implicitHeight: volumeModule.parentWindow ? volumeModule.parentWindow.barHeight : 30

visible: Pipewire.ready && !!Pipewire.defaultAudioSink

PwObjectTracker {
id: sinkTracker
objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton

onPressed: {
if (volumeModule.globalMenu) volumeModule.globalMenu.close();

const node = volumeModule.audioNode;
if (node) {
node.muted = !node.muted;
}
}

onWheel: wheel => {
if (volumeModule.globalMenu) volumeModule.globalMenu.close();

const node = volumeModule.audioNode;
if (!node || wheel.angleDelta.y === 0) return;

const step = 0.01;
const currentVolume = node.volume;

if (wheel.angleDelta.y > 0) {
node.volume = Math.min(1.0, currentVolume + step);
} else {
node.volume = Math.max(0.0, currentVolume - step);
}
}
}

Row {
id: volRow
anchors.verticalCenter: parent.verticalCenter

Text {
id: volPrefix
font.family: volumeModule.labelFontFamily
font.pixelSize: volumeModule.labelFontSize
color: volumeModule.labelColor
text: "VL: "
}

Text {
font: volPrefix.font
color: volumeModule.volMuted ? volumeModule.mutedColor : volumeModule.activeColor
text: volumeModule.volMuted ? "off" : `${volumeModule.volPercent}%`
}
}
}
