pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Io
import "../core"

Item {
id: mprisModule

required property var globalMenu
required property var parentWindow

property int pendingTrackId: -1
property int lastNotifiedTrackId: -1
property int notifyRetries: 0

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

implicitWidth: visible ? Math.min(mprisText.implicitWidth, maxWidth) : 0
implicitHeight: mprisModule.parentWindow ? mprisModule.parentWindow.barHeight : 30
visible: !!activePlayer

Connections {
target: mprisModule.activePlayer
ignoreUnknownSignals: true

function onPostTrackChanged() {
const player = mprisModule.activePlayer;

if (!player || !player.trackTitle) return;

mprisModule.pendingTrackId = player.uniqueId;
mprisModule.notifyRetries = 0;

notifyDebounce.restart();
}
}

Timer {
id: notifyDebounce
interval: 200
repeat: false

onTriggered: {
const player = mprisModule.activePlayer;

if (!player) return;

const id = player.uniqueId;

if (id !== mprisModule.pendingTrackId) return;

if (id === mprisModule.lastNotifiedTrackId) return;

if (!player.isPlaying || !player.lengthSupported) {
if (mprisModule.notifyRetries < 10) {
mprisModule.notifyRetries++;
notifyDebounce.restart();
}
return;
}

if (player.length > 0 && player.length < 15) return;

mprisModule.lastNotifiedTrackId = id;

notifyProcess.command = [
"notify-send",
player.trackArtist || "Desconhecido",
player.trackTitle
];

notifyProcess.running = true;
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

Text {
id: mprisText
anchors.verticalCenter: parent.verticalCenter
width: Math.min(implicitWidth, mprisModule.maxWidth)
elide: Text.ElideRight

font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize

readonly property var player: mprisModule.activePlayer
readonly property bool isPlaying: player ? player.isPlaying : false
readonly property string title: player ? player.trackTitle : ""
readonly property string artist: player && player.trackArtist ? player.trackArtist : ""
readonly property bool hasArtist: artist && artist.trim() !== "" && artist !== "Desconhecido"
readonly property string displayText: title
? `${isPlaying ? "|| " : "> "}${title}${hasArtist ? ` - ${artist}` : ""}`
: ""

color: isPlaying ? ThemeEngine.palette.mprisPlayingColor : ThemeEngine.palette.mprisPausedColor
text: displayText
}
}
