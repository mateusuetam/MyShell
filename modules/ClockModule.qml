pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../core"

Item {
id: clockModule

required property var globalMenu
required property var parentWindow

readonly property var ptBr: Qt.locale("pt_BR")

implicitWidth: clockRow.implicitWidth
implicitHeight: clockModule.parentWindow ? clockModule.parentWindow.barHeight : 30

SystemClock {
id: systemClock
precision: SystemClock.Minutes
}

Row {
id: clockRow
anchors.verticalCenter: parent.verticalCenter
readonly property date currentDate: systemClock.date
Text {
id: clockBase
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.clockLabelColor
text: `${clockModule.ptBr.toString(clockRow.currentDate, "ddd")} `
}
Text {
font: clockBase.font
color: ThemeEngine.palette.clockDayColor
text: clockModule.ptBr.toString(clockRow.currentDate, "d")
}
Text {
font: clockBase.font
color: clockBase.color
text: " de "
}
Text {
font: clockBase.font
color: ThemeEngine.palette.clockMonthColor
text: clockModule.ptBr.toString(clockRow.currentDate, "MMM")
}
Text {
font: clockBase.font
color: clockBase.color
text: ` - ${clockModule.ptBr.toString(clockRow.currentDate, "HH:mm")}`
}
}
}
