import QtQuick
import Quickshell.Services.Pipewire
import "../components/themeengine"

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
objects: [Pipewire.defaultAudioSource]
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton
onPressed: mouse => {
let menu = micModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
if (micModule.micNode) {
micModule.micNode.muted = !micModule.micNode.muted;
}
}
}
onWheel: wheel => {
let menu = micModule.globalMenu;
if (menu) {
menu.close();
}
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

Row {
id: micRow
anchors.verticalCenter: parent.verticalCenter
readonly property var micState: {
return micModule.micMuted ? {
color: micModule.mutedColor,
text: "off"
} : {
color: micModule.activeColor,
text: `${micModule.micPercent}%`
};
}
Text {
id: micPrefix
font.family: micModule.labelFontFamily
font.pixelSize: micModule.labelFontSize
color: micModule.labelColor
text: "MC: "
}
Text {
font: micPrefix.font
color: micRow.micState.color
text: micRow.micState.text
}
}
}
