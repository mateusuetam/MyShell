pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
id: splashWindow

property int currentStep: 0

WlrLayershell.namespace: "splash"
WlrLayershell.layer: WlrLayer.Overlay
WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

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
cursorShape: Qt.BlankCursor
onClicked: splashWindow.closeSplash()
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

Column {
anchors.centerIn: parent
spacing: 20

BootText {
text: "W A Y L A N D - Y U T A N I   C O R P ."
font.pixelSize: ThemeRegistry.appliedSplashTitleFontSize
font.bold: true
opacity: splashWindow.currentStep >= 1 ? 1 : 0
}

BootText {
text: "INTERFACE DO SISTEMA"
font.pixelSize: ThemeRegistry.appliedSplashStartFontSize
opacity: splashWindow.currentStep >= 2 ? 1 : 0
}

BootText {
text: "CARREGANDO NÚCLEO CENTRAL.............. OK"
opacity: splashWindow.currentStep >= 3 ? 1 : 0
}

BootText {
text: "VERIFICANDO SUPORTE DE VIDA............ OK"
opacity: splashWindow.currentStep >= 4 ? 1 : 0
}

BootText {
text: "SISTEMA OPERACIONAL ESTÁVEL............ PRONTO"
opacity: splashWindow.currentStep >= 5 ? 1 : 0
}
}

Timer {
id: bootSequence
interval: 400
running: true
repeat: true

property int tick: 0

onTriggered: {
switch (++tick) {
case 1:
splashWindow.currentStep = 1
break
case 2:
splashWindow.currentStep = 2
break
case 4:
splashWindow.currentStep = 3
break
case 5:
splashWindow.currentStep = 4
break
case 6:
splashWindow.currentStep = 5
break
case 9:
stop()
splashWindow.closeSplash()
break
}
}
}
}
