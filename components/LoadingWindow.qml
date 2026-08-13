pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

Item {
id: loadingManager

required property ShellScreen screen
property var activeLoading: null

Component {
id: loadingFactory

PanelWindow {
id: loadingWindow

property string mode: "boot"
property url nextWallpaper: ""
property int currentStep: 0

readonly property bool isBoot: mode === "boot"
readonly property bool isWallpaper: mode === "wallpaper"

readonly property int maxSteps: isBoot ? 8 : 6
readonly property int smoothThreshold: Math.floor(maxSteps * 0.66)
readonly property bool finalPhase: currentStep >= smoothThreshold

readonly property string titleText: isBoot ? "W A Y L A N D - Y U T A N I   C O R P ." : "S I S T E M A   O P T I C O ."

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

Component.onDestruction: {if (loadingManager.activeLoading === loadingWindow) loadingManager.activeLoading = null;}

function closeLoading(): void {
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
id: mainTitle
anchors.horizontalCenter: parent.horizontalCenter
text: loadingWindow.titleText
font.pixelSize: ThemeEngine.appliedLoadingTitleFontSize
font.bold: true
opacity: loadingWindow.currentStep >= 1 ? 1 : 0
}

Rectangle {
id: progressTrack
anchors.horizontalCenter: parent.horizontalCenter

width: Math.max(mainTitle.implicitWidth, 300)
height: 10

color: ThemeEngine.palette.loadingBarBackground
radius: ThemeEngine.palette.shellRadius
opacity: loadingWindow.currentStep >= 1 ? 1 : 0

Rectangle {
width: (parent.width / loadingWindow.maxSteps) * Math.min(loadingWindow.currentStep, loadingWindow.maxSteps)
height: parent.height

radius: ThemeEngine.palette.shellRadius
color: ThemeEngine.palette.loadingProgress

Behavior on width {
NumberAnimation {
duration: loadingWindow.finalPhase ? sequenceTimer.interval : sequenceTimer.interval * 0.6
easing.type: loadingWindow.finalPhase ? Easing.Linear : Easing.OutCubic
}
}
}
}
}
}

Timer {
id: sequenceTimer
readonly property int baseInterval: loadingWindow.isBoot ? 550 : 275
interval: baseInterval
running: true
repeat: true

onTriggered: {
loadingWindow.currentStep++

if (loadingWindow.finalPhase) {
interval = baseInterval * 0.7
} else {
interval = baseInterval * (0.6 + Math.random() * 0.9)
}

if (
loadingWindow.isWallpaper && loadingWindow.currentStep === 4
) {
WallpaperEngine.currentWallpaper = loadingWindow.nextWallpaper
}

if (
loadingWindow.currentStep > loadingWindow.maxSteps
) {
stop()
fadeOutAnim.start()
}
}
}
}
}

function spawnLoading(mode, newWallpaper) {
if (loadingManager.activeLoading) loadingManager.activeLoading.destroy()
loadingManager.activeLoading = loadingFactory.createObject
(loadingManager,{screen: loadingManager.screen, mode: mode, nextWallpaper: newWallpaper ?? ""})
}

Component.onCompleted: {spawnLoading("boot")}

Connections {
target: WallpaperEngine
function onTransitionRequested(path) {
loadingManager.spawnLoading("wallpaper", path)
}
}
}
