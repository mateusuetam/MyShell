import QtQuick
import Quickshell.Services.Pipewire
import "../components/themeengine"

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
objects: [Pipewire.defaultAudioSink]
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton
onPressed: mouse => {
let menu = volumeModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
if (volumeModule.audioNode) {
volumeModule.audioNode.muted = !volumeModule.audioNode.muted;
}
}
}
onWheel: wheel => {
let menu = volumeModule.globalMenu;
if (menu) {
menu.close();
}
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

Row {
id: volRow
anchors.verticalCenter: parent.verticalCenter
readonly property var volState: {
return volumeModule.volMuted ? {
color: volumeModule.mutedColor,
text: "off"
} : {
color: volumeModule.activeColor,
text: `${volumeModule.volPercent}%`
};
}
Text {
id: volPrefix
font.family: volumeModule.labelFontFamily
font.pixelSize: volumeModule.labelFontSize
color: volumeModule.labelColor
text: "VL: "
}
Text {
font: volPrefix.font
color: volRow.volState.color
text: volRow.volState.text
}
}
}
