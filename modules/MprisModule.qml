import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Io
import "../core"

Item {
id: mprisModule
required property var globalMenu
required property var parentWindow

readonly property int maxWidth: 450

readonly property var activePlayer: {
const list = Mpris.players.values;
if (!list.length) return null;

for (let i = 0; i < list.length; i++) {
const p = list[i];
if (p && !p.dbusName.includes("playerctld") && p.trackTitle) {
return p;
}
}
return null;
}

implicitWidth: visible ? Math.min(mprisRow.implicitWidth, maxWidth) : 0
implicitHeight: mprisModule.parentWindow ? mprisModule.parentWindow.barHeight : 30
visible: !!activePlayer

Connections {
target: mprisModule.activePlayer
ignoreUnknownSignals: true

function onPostTrackChanged() {
notifyDebounce.restart();
}
}

Timer {
id: notifyDebounce
interval: 200
repeat: false
onTriggered: {
const player = mprisModule.activePlayer;
if (player && player.trackTitle) {
const title = player.trackTitle;
const artist = player.trackArtist || "Desconhecido";

notifyProcess.command = [
"notify-send",
artist,
title
];
notifyProcess.running = true;
}
}
}

Process {
id: notifyProcess
}

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

if (!player) return;

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

Text {
id: mprisText
width: Math.min(implicitWidth, mprisModule.maxWidth)
elide: Text.ElideRight
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize

readonly property var player: mprisModule.activePlayer
readonly property bool isPlaying: player ? player.isPlaying : false
readonly property string title: player ? player.trackTitle : ""
readonly property string artist: player && player.trackArtist ? player.trackArtist : "Desconhecido"

color: isPlaying ? ThemeRegistry.mprisPlayingColor : ThemeRegistry.mprisPausedColor
text: title ? `${isPlaying ? "|| " : "> "}${title} - ${artist}` : ""
}
}
}
