pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
id: loadingWindow

property int currentStep: 0

readonly property int maxSteps: 8
readonly property int smoothThreshold: Math.floor(maxSteps * 0.66)
readonly property bool finalPhase: currentStep >= smoothThreshold

readonly property string titleText: "W A Y L A N D - Y U T A N I   C O R P ."

WlrLayershell.namespace: "loading"
WlrLayershell.layer: WlrLayer.Overlay
WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

exclusionMode: ExclusionMode.Ignore

anchors {
top: true
right: true
bottom: true
left: true
}

color: "transparent"

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
onFinished: loadingWindow.destroy()
}

MouseArea {
anchors.fill: parent
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

component TerminalText: Text {
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

Timer {
id: sequenceTimer

readonly property int baseInterval: 550

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

if (loadingWindow.currentStep > loadingWindow.maxSteps) {
stop()
fadeOutAnim.start()
}
}
}
}
}
