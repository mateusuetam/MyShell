pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
id: loadingWindow

function getGreeting(hour: int): string {
if (hour >= 5 && hour < 12) return "Bom dia!"
if (hour >= 12 && hour < 18) return "Boa tarde!"
if (hour >= 18 && hour < 23) return "Boa noite!"
return "Boa madrugada!"
}

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

SystemClock {
id: clock
precision: SystemClock.Minutes
}

Rectangle {
id: visualWrapper
anchors.fill: parent
color: ThemeEngine.palette.loadingBackground
opacity: 1.0

NumberAnimation {
id: fadeOutAnim
target: visualWrapper
property: "opacity"
to: 0.0
duration: 500
easing.type: Easing.InOutQuad
onFinished: loadingWindow.destroy()
}

MouseArea {
anchors.fill: parent
acceptedButtons: Qt.NoButton
cursorShape: Qt.BlankCursor
}

Column {
anchors.centerIn: parent
spacing: 10

Text {
anchors.horizontalCenter: parent.horizontalCenter
text: Qt.formatTime(clock.date, "HH:mm")
color: ThemeEngine.palette.loadingText
opacity: 0.65
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLoadingTitleFontSize
}

Text {
anchors.horizontalCenter: parent.horizontalCenter
text: loadingWindow.getGreeting(clock.hours)
color: ThemeEngine.palette.loadingText
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLoadingLabelFontSize
font.weight: Font.Bold
opacity: 1.0
}
}
}

Timer {
interval: 3000
running: true
repeat: false
onTriggered: fadeOutAnim.start()
}
}
