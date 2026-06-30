import QtQuick
import Quickshell.Services.Mpris
import "../components/themeengine"

Item {
id: mprisModule

required property var globalMenu
required property var parentWindow

readonly property color playingColor: ThemeRegistry.mprisPlayingColor
readonly property color pausedColor: ThemeRegistry.mprisPausedColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

readonly property int maxWidth: 450

readonly property var activePlayer: {
const list = Mpris.players.values;
if (!list.length)
return null;
for (const p of list) {
if (p?.dbusName?.includes("playerctld"))
continue;
if (p?.trackTitle)
return p;
}
return null;
}

implicitWidth: visible ? Math.min(mprisRow.implicitWidth, maxWidth) : 0
implicitHeight: mprisModule.parentWindow ? mprisModule.parentWindow.barHeight : 30

visible: !!activePlayer

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
onPressed: mouse => {
let menu = mprisModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
const player = mprisModule.activePlayer;
if (!player)
return;
if (mouse.button === Qt.LeftButton && player.canTogglePlaying) {
player.togglePlaying();
} else if (mouse.button === Qt.RightButton && player.canGoNext) {
player.next();
} else if (mouse.button === Qt.MiddleButton && player.canGoPrevious) {
player.previous();
}
}
}

Row {
id: mprisRow
anchors.verticalCenter: parent.verticalCenter
readonly property var playerState: {
const player = mprisModule.activePlayer;
if (!player || !player.trackTitle) {
return {
color: mprisModule.pausedColor,
text: ""
};
}
const icon = player.isPlaying ? "|| " : "> ";
const artist = player.trackArtist || "Desconhecido";
const uiColor = player.isPlaying ? mprisModule.playingColor : mprisModule.pausedColor;
return {
color: uiColor,
text: `${icon}${player.trackTitle} - ${artist}`
};
}
Text {
width: Math.min(implicitWidth, mprisModule.maxWidth)
elide: Text.ElideRight
font.family: mprisModule.labelFontFamily
font.pixelSize: mprisModule.labelFontSize
color: mprisRow.playerState.color
text: mprisRow.playerState.text
}
}
}
