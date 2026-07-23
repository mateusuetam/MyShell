pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
id: splashWindow

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

WlrLayershell.namespace: "splash"
WlrLayershell.layer: splashWindow.isBoot ? WlrLayer.Overlay : WlrLayer.Bottom
WlrLayershell.keyboardFocus: splashWindow.isBoot ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

exclusionMode: ExclusionMode.Ignore

anchors {
top: true
bottom: true
left: true
right: true
}

color: ThemeRegistry.splashBackground

function closeSplash(): void {
splashWindow.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
splashWindow.destroy();
}

MouseArea {
anchors.fill: parent
enabled: splashWindow.isBoot
visible: splashWindow.isBoot
hoverEnabled: true
acceptedButtons: Qt.NoButton
cursorShape: Qt.BlankCursor
}

Canvas {
anchors.fill: parent
renderStrategy: Canvas.Cooperative
onPaint: {
const ctx = getContext("2d")
ctx.clearRect(0, 0, width, height)
ctx.strokeStyle = ThemeRegistry.splashCanvas
ctx.globalAlpha = 0.03
ctx.beginPath()
for (let y = 0; y < height; y += 4) {
ctx.moveTo(0, y)
ctx.lineTo(width, y)
}
ctx.stroke()
}
}

component BootText : Text {
color: ThemeRegistry.splashText
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedSplashLabelFontSize
Behavior on opacity {
NumberAnimation {
duration: 100
}
}
}

Timer {
id: sequenceTimer
interval: splashWindow.isBoot ? 500 : 250
running: true
repeat: true

onTriggered: {
splashWindow.currentStep++

if (splashWindow.isWallpaper && splashWindow.currentStep === 4)
WallpaperEngine.currentWallpaper = splashWindow.nextWallpaper

if ((splashWindow.isBoot && splashWindow.currentStep === 8) ||
(splashWindow.isWallpaper && splashWindow.currentStep === 6)) {

stop()
splashWindow.closeSplash()
}
}
}

Column {
anchors.centerIn: parent
spacing: 20

BootText {
text: splashWindow.messages[0]
font.pixelSize: ThemeRegistry.appliedSplashTitleFontSize
font.bold: true
opacity: splashWindow.currentStep >= 1 ? 1 : 0
}

BootText {
text: splashWindow.messages[1]
font.pixelSize: ThemeRegistry.appliedSplashStartFontSize
opacity: splashWindow.currentStep >= 2 ? 1 : 0
}

BootText {
text: splashWindow.messages[2]
opacity: splashWindow.currentStep >= 3 ? 1 : 0
}

BootText {
text: splashWindow.messages[3]
opacity: splashWindow.currentStep >= 4 ? 1 : 0
}

BootText {
text: splashWindow.messages[4]
opacity: splashWindow.currentStep >= 5 ? 1 : 0
}
}
}
