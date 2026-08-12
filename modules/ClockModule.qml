pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../core"

Item {
id: clockModule

required property var globalMenu
required property var parentWindow

readonly property var ptBr: Qt.locale("pt_BR")

property bool showFullDate: false

implicitWidth: clockRow.implicitWidth
implicitHeight: clockModule.parentWindow ? clockModule.parentWindow.barHeight : 30

SystemClock {
id: systemClock
precision: SystemClock.Minutes
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.RightButton
onPressed: (mouse) => {
if (mouse.button === Qt.RightButton) {
clockModule.showFullDate = !clockModule.showFullDate
}
}
}

Row {
id: clockRow
anchors.verticalCenter: parent.verticalCenter
readonly property date currentDate: systemClock.date

Text {
id: clockBase
visible: clockModule.showFullDate
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.clockLabelColor
text: `${clockModule.ptBr.toString(clockRow.currentDate, "ddd")} `
}
Text {
visible: clockModule.showFullDate
font: clockBase.font
color: ThemeEngine.palette.clockDayColor
text: clockModule.ptBr.toString(clockRow.currentDate, "d")
}
Text {
visible: clockModule.showFullDate
font: clockBase.font
color: clockBase.color
text: " de "
}
Text {
visible: clockModule.showFullDate
font: clockBase.font
color: ThemeEngine.palette.clockMonthColor
text: clockModule.ptBr.toString(clockRow.currentDate, "MMM")
}

Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: clockBase.color
text: clockModule.showFullDate ? ` - ${clockModule.ptBr.toString(clockRow.currentDate, "HH:mm")}` : clockModule.ptBr.toString(clockRow.currentDate, "HH:mm")
}
}
}
