pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import "../core"

Item {
id: idleModule

required property var globalMenu
required property var parentWindow

readonly property bool isActive: inhibitor.enabled

implicitWidth: idleRow.implicitWidth
implicitHeight: idleModule.parentWindow ? idleModule.parentWindow.barHeight : 30

IdleInhibitor {
id: inhibitor
window: idleModule.parentWindow
enabled: false
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton
onPressed: mouse => {
let menu = idleModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
inhibitor.enabled = !inhibitor.enabled;
}
}
}

Row {
id: idleRow
anchors.verticalCenter: parent.verticalCenter
Text {
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: idleModule.isActive ? ThemeEngine.palette.idleActivatedColor : ThemeEngine.palette.idleDeactivatedColor
text: idleModule.isActive ? "ACTIVE" : "IDLING"
}
}
}
