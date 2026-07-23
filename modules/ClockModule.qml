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
readonly property var formattedParts: {
const d = systemClock.date;
return {
weekday: clockModule.ptBr.toString(d, "ddd"),
day: clockModule.ptBr.toString(d, "d"),
month: clockModule.ptBr.toString(d, "MMM"),
time: clockModule.ptBr.toString(d, "HH:mm")
};
}
Text {
id: clockBase
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.clockLabelColor
text: `{ ${clockRow.formattedParts.weekday} `
}
Text {
font: clockBase.font
color: ThemeEngine.palette.clockDayColor
text: clockRow.formattedParts.day
}
Text {
font: clockBase.font
color: clockBase.color
text: " de "
}
Text {
font: clockBase.font
color: ThemeEngine.palette.clockMonthColor
text: clockRow.formattedParts.month
}
Text {
font: clockBase.font
color: clockBase.color
text: ` | ${clockRow.formattedParts.time} }`
}
}
}
