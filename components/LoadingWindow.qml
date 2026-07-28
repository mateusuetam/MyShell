pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

Item {
id: loadingManager

required property var screen

Component {
id: loadingFactory

PanelWindow {
id: loadingWindow

property string mode: "boot"
property url nextWallpaper: ""
property int currentStep: 0

readonly property bool isBoot: mode === "boot"
readonly property bool isWallpaper: mode === "wallpaper"

readonly property var bootMessages: [
"W A Y L A N D - Y U T A N I   C O R P .",
"INTERFACE DO SISTEMA",
"CARREGANDO NÚCLEO CENTRAL.............. OK",
"VERIFICANDO SUPORTE DE VIDA............ OK",
"SISTEMA OPERACIONAL ESTÁVEL............ PRONTO"
]

readonly property var wallpaperMessages: [
"S I S T E M A   O P T I C O .",
"RECALIBRANDO MATRIZ DE VÍDEO",
"DESCARREGANDO CACHE.............. OK",
"APLICANDO NOVO FEED VISUAL....... OK",
"SINCRONIZAÇÃO COMPLETA........... PRONTO"
]

readonly property var messages: isBoot ? bootMessages : wallpaperMessages

WlrLayershell.namespace: "loading"
WlrLayershell.layer: loadingWindow.isBoot ? WlrLayer.Overlay : WlrLayer.Bottom
WlrLayershell.keyboardFocus: loadingWindow.isBoot ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

exclusionMode: ExclusionMode.Ignore

anchors {
top: true
right: true
bottom: true
left: true
}

color: "transparent"

function closeLoading(): void {
loadingWindow.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
loadingWindow.destroy();
}

Rectangle {
id: visualWrapper
anchors.fill: parent
color: ThemeEngine.palette.loadingBackground

NumberAnimation {
id: fadeOutAnim
target: visualWrapper
property: "opacity"
to: 0.0
duration: 400
easing.type: Easing.InOutQuad
onFinished: loadingWindow.closeLoading()
}

MouseArea {
anchors.fill: parent
enabled: loadingWindow.isBoot
visible: loadingWindow.isBoot
acceptedButtons: Qt.NoButton
cursorShape: Qt.BlankCursor
}

Canvas {
anchors.fill: parent
renderStrategy: Canvas.Cooperative
onPaint: {
const ctx = getContext("2d")
ctx.clearRect(0, 0, width, height)
ctx.strokeStyle = ThemeEngine.palette.loadingCanvas
ctx.globalAlpha = 0.1
ctx.beginPath()
for (let y = 0; y < height; y += 4) {
ctx.moveTo(0, y)
ctx.lineTo(width, y)
}
ctx.stroke()
}
}

component TerminalText : Text {
color: ThemeEngine.palette.loadingText
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLoadingLabelFontSize
Behavior on opacity {
NumberAnimation {
duration: 100
}
}
}

Column {
anchors.centerIn: parent
spacing: 20

TerminalText {
text: loadingWindow.messages[0]
font.pixelSize: ThemeEngine.appliedLoadingTitleFontSize
font.bold: true
opacity: loadingWindow.currentStep >= 1 ? 1 : 0
}

TerminalText {
text: loadingWindow.messages[1]
font.pixelSize: ThemeEngine.appliedLoadingStartFontSize
opacity: loadingWindow.currentStep >= 2 ? 1 : 0
}

TerminalText {
text: loadingWindow.messages[2]
opacity: loadingWindow.currentStep >= 3 ? 1 : 0
}

TerminalText {
text: loadingWindow.messages[3]
opacity: loadingWindow.currentStep >= 4 ? 1 : 0
}

TerminalText {
text: loadingWindow.messages[4]
opacity: loadingWindow.currentStep >= 5 ? 1 : 0
}
}
}

Timer {
id: sequenceTimer
interval: loadingWindow.isBoot ? 550 : 275
running: true
repeat: true

onTriggered: {
loadingWindow.currentStep++

if (loadingWindow.isWallpaper && loadingWindow.currentStep === 4)
WallpaperEngine.currentWallpaper = loadingWindow.nextWallpaper

if ((loadingWindow.isBoot && loadingWindow.currentStep === 8) ||
(loadingWindow.isWallpaper && loadingWindow.currentStep === 6)) {

stop()
fadeOutAnim.start()
}
}
}
}
}

function spawnLoading(mode, newWallpaper) {
loadingFactory.createObject(loadingManager, {
screen: loadingManager.screen,
mode: mode,
nextWallpaper: newWallpaper || ""
});
}

Component.onCompleted: spawnLoading("boot", "")

Connections {
target: WallpaperEngine
function onTransitionRequested(path) {
loadingManager.spawnLoading("wallpaper", path);
}
}
}
