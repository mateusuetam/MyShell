import QtQuick
import Quickshell.Services.Pipewire
import "../core"

Item {
id: micModule

required property var globalMenu
required property var parentWindow

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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
color: ThemeRegistry.microphoneLabelColor
text: "MC: "
}

Text {
font: micPrefix.font
color: micModule.micMuted ? ThemeRegistry.microphoneMutedColor : ThemeRegistry.microphoneActiveColor
text: micModule.micMuted ? "off" : `${micModule.micPercent}%`
}
}
}
