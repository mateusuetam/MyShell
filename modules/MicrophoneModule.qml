import QtQuick
import Quickshell.Services.Pipewire
import "../core"

Item {
id: micModule

required property var globalMenu
required property var parentWindow

readonly property color mutedColor: ThemeRegistry.microphoneMutedColor
readonly property color activeColor: ThemeRegistry.microphoneActiveColor
readonly property color labelColor: ThemeRegistry.microphoneLabelColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

readonly property var micNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
readonly property int micPercent: micNode ? Math.round(micNode.volume * 100) : 0
readonly property bool micMuted: micNode ? micNode.muted : false

implicitWidth: micRow.implicitWidth
implicitHeight: micModule.parentWindow ? micModule.parentWindow.barHeight : 30

visible: Pipewire.ready && !!Pipewire.defaultAudioSource

PwObjectTracker {
id: sourceTracker
objects: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton

onPressed: {
if (micModule.globalMenu) micModule.globalMenu.close();

const node = micModule.micNode;
if (node) {
node.muted = !node.muted;
}
}

onWheel: wheel => {
if (micModule.globalMenu) micModule.globalMenu.close();

const node = micModule.micNode;
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
id: micRow
anchors.verticalCenter: parent.verticalCenter

Text {
id: micPrefix
font.family: micModule.labelFontFamily
font.pixelSize: micModule.labelFontSize
color: micModule.labelColor
text: "MC: "
}

Text {
font: micPrefix.font
color: micModule.micMuted ? micModule.mutedColor : micModule.activeColor
text: micModule.micMuted ? "off" : `${micModule.micPercent}%`
}
}
}
