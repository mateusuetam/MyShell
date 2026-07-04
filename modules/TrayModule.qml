pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray

Item {
id: trayModule

required property var globalMenu
required property var parentWindow

implicitWidth: trayLayout.implicitWidth
implicitHeight: trayModule.parentWindow ? trayModule.parentWindow.barHeight : 30

visible: !!SystemTray.items

Row {
id: trayLayout
height: parent.height
spacing: 10
anchors.verticalCenter: parent.verticalCenter

Repeater {
model: SystemTray.items
delegate: Item {
id: trayItemDelegate

width: 20
height: 20
anchors.verticalCenter: parent.verticalCenter

required property var modelData
readonly property var trayItem: trayItemDelegate.modelData

Image {
anchors.fill: parent
source: trayItemDelegate.trayItem?.icon ?? ""
fillMode: Image.PreserveAspectFit
asynchronous: true
sourceSize.width: 20
sourceSize.height: 20
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
let menu = trayModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
let item = trayItemDelegate.trayItem;
if (!item)
return;
if (mouse.button === Qt.LeftButton) {
item.activate();
} else if (mouse.button === Qt.RightButton && item.hasMenu && item.menu && menu) {
menu.openMenu(trayModule.parentWindow, trayItemDelegate, item.menu);
}
}
}
}
}
}
}
