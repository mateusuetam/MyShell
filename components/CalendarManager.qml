pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: root

property var globalMenu: null

property int _calMonth: -1
property int _calYear: -1

readonly property var _ptBrLocale: Qt.locale("pt_BR")

function toggleCalendar(targetWindow, anchorItem) {
if (globalMenu && globalMenu.visible && globalMenu._currentAnchorItem === anchorItem) {
globalMenu.close();
return;
}

const today = new Date();

_calMonth = today.getMonth();
_calYear = today.getFullYear();

if (globalMenu) {
globalMenu.showSearchInput = false;

globalMenu.openMenu(
targetWindow,
anchorItem,
_generateCalendarModel(),
"calendar",
() => _generateCalendarModel()
);
}
}

function _generateCalendarModel() {
const date = new Date(_calYear, _calMonth, 1);

let monthStr = root._ptBrLocale.toString(date, "MMM");
monthStr = monthStr.charAt(0).toUpperCase() + monthStr.slice(1);

let model = [];

model.push({
text: monthStr + " " + _calYear,
align: "center",
enabled: false
});

model.push({
type: "splitAction",
actions: [
{
text: "< Ant.",
onTrigger: function() {
_calMonth--;

if (_calMonth < 0) { _calMonth = 11; _calYear--; }
if (root.globalMenu) root.globalMenu.refresh();
}
},
{
text: "Próx. >",
onTrigger: function() {
_calMonth++;

if (_calMonth > 11) { _calMonth = 0; _calYear++; }
if (root.globalMenu) root.globalMenu.refresh();
}
}
]
});

model.push({ type: "separator" });

model.push({
type: "gridRow",
items: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
});

const firstDay = date.getDay();
const daysInMonth = new Date(_calYear, _calMonth + 1, 0).getDate();

const today = new Date();
const isCurrentMonthAndYear = today.getMonth() === _calMonth && today.getFullYear() === _calYear;

let currentWeek = [];

for (let i = 0; i < firstDay; i++) currentWeek.push("");

let dayOfWeek = firstDay;

for (let day = 1; day <= daysInMonth; day++) {
currentWeek.push({
text: day.toString(),
isToday: isCurrentMonthAndYear && today.getDate() === day
});

if (dayOfWeek === 6 || day === daysInMonth) {
while (currentWeek.length < 7) currentWeek.push("");

model.push({
type: "gridRow",
items: currentWeek
});

currentWeek = [];
}

dayOfWeek = (dayOfWeek + 1) % 7;
}

return model;
}
}
