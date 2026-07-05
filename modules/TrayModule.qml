pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import Quickshell
import Quickshell.Services.SystemTray
import "../core"

Item {
id: trayModule
required property var globalMenu
required property var parentWindow

Instantiator {
id: trayData
model: SystemTray.items
onObjectAdded: (index, object) => trayModule.updateMenu(false)
onObjectRemoved: (index, object) => trayModule.updateMenu(false)
delegate: QtObject {
required property var modelData
readonly property var item: modelData
}
}

visible: trayData.count > 0
implicitWidth: trayText.implicitWidth + 10
implicitHeight: trayModule.parentWindow ? trayModule.parentWindow.barHeight : 30

Text {
id: trayText
text: "<"
color: ThemeRegistry.menuTextColor
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
anchors.centerIn: parent
verticalAlignment: Text.AlignVCenter
horizontalAlignment: Text.AlignHCenter
}

function getAppName(trayItem) {
if (!trayItem) return "App";

const appId = trayItem.id || "";
const appTitle = trayItem.title || "";

if (appId.includes("chrome_status_icon")) {
const electronName = appTitle || trayItem.tooltipTitle || "";
if (electronName) {
const entry = DesktopEntries.heuristicLookup(electronName);
if (entry && entry.name) return entry.name;

const dashIdx = electronName.indexOf(" - ");
return dashIdx !== -1 ? electronName.substring(0, dashIdx) : electronName;
}
return "Electron App";
}

const lookupKey = appId || appTitle;
if (lookupKey) {
const entry = DesktopEntries.heuristicLookup(lookupKey);
if (entry && entry.name) return entry.name;
}

return appTitle || appId || "App";
}

function buildTrayModel() {
const trayListModel = [];
const count = trayData.count;
const parentWin = trayModule.parentWindow;

for (let i = 0; i < count; i++) {
const delegateObj = trayData.objectAt(i);

if (!delegateObj || !delegateObj.item) continue;

const trayItem = delegateObj.item;
const itemText = trayModule.getAppName(trayItem);

trayListModel.push({
text: itemText,
onTrigger: () => {
if (trayItem.hasMenu && trayItem.menu) {
Qt.callLater(() => {
trayModule.globalMenu.openMenu(parentWin, trayButton, trayItem.menu);
});
} else {
trayItem.activate();
}
}
});
}

return trayListModel;
}

function updateMenu(forceOpen) {
const menu = trayModule.globalMenu;
if (!menu) return;
if (!forceOpen && !menu.visible) return;

const parentWin = trayModule.parentWindow;
const trayListModel = trayModule.buildTrayModel();

menu.showSearchInput = false;

if (!menu.visible) {
if (forceOpen && trayListModel.length > 0) {
menu.openMenu(parentWin, trayButton, trayListModel);
}
return;
}

if (trayListModel.length > 0) {
menu.menuModel = trayListModel;
} else {
menu.close();
}
}

MouseArea {
id: trayButton
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton
onClicked: {
if (trayModule.globalMenu) {
trayModule.globalMenu.close();
}
Qt.callLater(() => trayModule.updateMenu(true));
}
}
}
