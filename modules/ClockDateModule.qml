pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../core"

Item {
id: clockDateModule

required property var globalMenu
required property var parentWindow
property bool showFullDate: false
property int _calMonth: -1
property int _calYear: -1
readonly property var ptBr: Qt.locale("pt_BR")

implicitWidth: clockRow.implicitWidth
implicitHeight: clockDateModule.parentWindow ? clockDateModule.parentWindow.barHeight : 30

SystemClock {
id: systemClock
precision: SystemClock.Minutes
}

function toggleCalendar() {
if (clockDateModule.globalMenu && clockDateModule.globalMenu.visible && clockDateModule.globalMenu._currentAnchorItem === clockDateModule) {
clockDateModule.globalMenu.close();
return;
}

const today = new Date();

_calMonth = today.getMonth();
_calYear = today.getFullYear();

if (!clockDateModule.globalMenu) return;

clockDateModule.globalMenu.showSearchInput = false;
clockDateModule.globalMenu.openMenu(clockDateModule.parentWindow, clockDateModule, _generateCalendarModel(), "calendar", () => _generateCalendarModel());
}

function _generateCalendarModel() {
const date = new Date(_calYear, _calMonth, 1);
let monthStr = clockDateModule.ptBr.toString(date, "MMM");

monthStr = monthStr.charAt(0).toUpperCase() + monthStr.slice(1);

let model = [];

model.push({text: monthStr + " " + _calYear, align: "center", enabled: false});

model.push({
type: "splitAction",

actions: [
{
text: "< Ant.",
onTrigger: function() {
_calMonth--;

if (_calMonth < 0) {
_calMonth = 11;
_calYear--;
}

if (clockDateModule.globalMenu) clockDateModule.globalMenu.refresh();
}
},

{
text: "Próx. >",
onTrigger: function() {
_calMonth++;

if (_calMonth > 11) {
_calMonth = 0;
_calYear++;
}

if (clockDateModule.globalMenu) clockDateModule.globalMenu.refresh();
}
}
]
});

model.push({type: "separator"});

model.push({type: "gridRow", items: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]});

const firstDay = date.getDay();
const daysInMonth = new Date(_calYear, _calMonth + 1, 0).getDate();
const today = new Date();
const isCurrentMonthAndYear = today.getMonth() === _calMonth && today.getFullYear() === _calYear;
let currentWeek = [];

for (let i = 0; i < firstDay; i++) currentWeek.push("");

let dayOfWeek = firstDay;

for (let day = 1; day <= daysInMonth; day++) {
currentWeek.push({text: day.toString(), isToday: isCurrentMonthAndYear && today.getDate() === day});

if (dayOfWeek === 6 || day === daysInMonth) {
while (currentWeek.length < 7) currentWeek.push("");
model.push({type: "gridRow", items: currentWeek});
currentWeek = [];
}

dayOfWeek = (dayOfWeek + 1) % 7;
}
return model;
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
if (mouse.button === Qt.RightButton) clockDateModule.showFullDate = !clockDateModule.showFullDate;
else if (mouse.button === Qt.LeftButton) clockDateModule.toggleCalendar();
}
}

Row {
id: clockRow
anchors.verticalCenter: parent.verticalCenter
readonly property date currentDate: systemClock.date

Text {
id: clockBase
visible: clockDateModule.showFullDate
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.clockLabelColor
text: `${clockDateModule.ptBr.toString(clockRow.currentDate, "ddd")} `
}

Text {
visible: clockDateModule.showFullDate
font: clockBase.font
color: ThemeEngine.palette.clockDayColor
text: clockDateModule.ptBr.toString(clockRow.currentDate, "d")
}

Text {
visible: clockDateModule.showFullDate
font: clockBase.font
color: clockBase.color
text: " de "
}

Text {
visible: clockDateModule.showFullDate
font: clockBase.font
color: ThemeEngine.palette.clockMonthColor
text: clockDateModule.ptBr.toString(clockRow.currentDate, "MMM")
}

Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: clockBase.color
text: clockDateModule.showFullDate ? ` - ${clockDateModule.ptBr.toString(clockRow.currentDate, "HH:mm")}` : clockDateModule.ptBr.toString(clockRow.currentDate, "HH:mm")
}
}
}
