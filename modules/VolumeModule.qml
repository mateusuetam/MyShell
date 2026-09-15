pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import "../core"

Item {
id: volumeModule

required property var globalMenu
required property var parentWindow

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

onPressed: mouse => {
mouse.accepted = true;
if (volumeModule.globalMenu) volumeModule.globalMenu.close();
if (volumeModule.audioNode) volumeModule.audioNode.muted = !volumeModule.audioNode.muted;
}

onWheel: wheel => {
if (volumeModule.globalMenu) volumeModule.globalMenu.close();
if (!volumeModule.audioNode || wheel.angleDelta.y === 0) return;
if (wheel.angleDelta.y > 0) volumeModule.audioNode.volume = Math.min(1.0, volumeModule.audioNode.volume + 0.01);
else volumeModule.audioNode.volume = Math.max(0.0, volumeModule.audioNode.volume - 0.01);
}
}

Row {
id: volRow
anchors.verticalCenter: parent.verticalCenter

Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: volumeModule.volMuted ? ThemeEngine.palette.volumeMutedColor : ThemeEngine.palette.volumeActiveColor
text: volumeModule.volMuted ? "VL: off" : `VL: ${volumeModule.volPercent}%`
}
}
}
