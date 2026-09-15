pragma ComponentBehavior: Bound
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

onPressed: mouse => {
mouse.accepted = true;
if (micModule.globalMenu) micModule.globalMenu.close();
if (micModule.micNode) micModule.micNode.muted = !micModule.micNode.muted;
}

onWheel: wheel => {
if (micModule.globalMenu) micModule.globalMenu.close();
if (!micModule.micNode || wheel.angleDelta.y === 0) return;
if (wheel.angleDelta.y > 0) micModule.micNode.volume = Math.min(1.0, micModule.micNode.volume + 0.01);
else micModule.micNode.volume = Math.max(0.0, micModule.micNode.volume - 0.01);
}
}

Row {
id: micRow
anchors.verticalCenter: parent.verticalCenter
Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: micModule.micMuted ? ThemeEngine.palette.microphoneMutedColor : ThemeEngine.palette.microphoneActiveColor
text: micModule.micMuted ? "MC: off" : `MC: ${micModule.micPercent}%`
}
}
}
