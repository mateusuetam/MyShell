pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../core"

PopupWindow {
id: notifyPopup

signal clicked()

readonly property color notifyColor: {
if (!currentNotify) {
return ThemeEngine.palette.borderColor;
}
switch (currentNotify.urgency) {
case NotificationUrgency.Low:
return ThemeEngine.palette.borderLowColor;
case NotificationUrgency.Normal:
return ThemeEngine.palette.borderNormalColor;
case NotificationUrgency.Critical:
return ThemeEngine.palette.borderCriticalColor;
default:
return ThemeEngine.palette.borderColor;
}
}

property var notifyQueue: []
property var currentNotify: null

required property QtObject targetWindow

Binding {
target: ThemeEngine.palette
property: "dynamicBorderColor"
value: notifyPopup.notifyColor
}

anchor.window: targetWindow
anchor.rect.y: 29
anchor.rect.x: Quickshell.screens[0] ? Math.round((Quickshell.screens[0].width - implicitWidth) / 2) : 0
implicitWidth: 350
implicitHeight: contentColumn.implicitHeight + 14

color: "transparent"
visible: false

NotificationServer {
id: notifyServer
imageSupported: false
actionsSupported: true
actionIconsSupported: true
bodySupported: true
bodyImagesSupported: false
bodyMarkupSupported: true
bodyHyperlinksSupported: true

onNotification: notification => {
notification.tracked = true;
notifyPopup.addNotification(notification);
}
}

function addNotification(n) {
notifyQueue.push(n);
if (!currentNotify && !animateIn.running && !animateOut.running) {
nextNotification();
}
}

function nextNotification() {
if (notifyQueue.length > 0) {
currentNotify = notifyQueue.shift();

headerText.text = currentNotify.summary;
bodyText.text = currentNotify.body;

notifyPopup.visible = true;
animateIn.start();

let timeout = 3000;
if (currentNotify.expireTimeout > 0) {
timeout = currentNotify.expireTimeout * 1000;
} else if (currentNotify.urgency === NotificationUrgency.Critical) {
timeout = 4000;
} else if (currentNotify.urgency === NotificationUrgency.Low) {
timeout = 2000;
}

dismissTimer.interval = timeout;
dismissTimer.start();
} else {
notifyPopup.visible = false;
}
}

Timer {
id: dismissTimer
repeat: false
onTriggered: animateOut.start()
}

NumberAnimation {
id: animateIn
target: visualBox
property: "y"
from: -visualBox.height
to: 0
duration: 180
easing.type: Easing.OutQuad
}

NumberAnimation {
id: animateOut
target: visualBox
property: "y"
from: 0
to: -visualBox.height
duration: 150
easing.type: Easing.InQuad
onFinished: {
if (notifyPopup.currentNotify) {
notifyPopup.currentNotify.dismiss();
notifyPopup.currentNotify = null;
}
notifyPopup.nextNotification();
}
}

Rectangle {
id: visualBox
width: parent.width
height: parent.height
y: -height

color: ThemeEngine.palette.backgroundColor

Rectangle {
anchors.left: parent.left
anchors.top: parent.top
anchors.bottom: parent.bottom
width: 1
color: notifyPopup.notifyColor
}

Rectangle {
anchors.right: parent.right
anchors.top: parent.top
anchors.bottom: parent.bottom
width: 1
color: notifyPopup.notifyColor
}

Rectangle {
anchors.bottom: parent.bottom
anchors.left: parent.left
anchors.right: parent.right
height: 1
color: notifyPopup.notifyColor
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
notifyPopup.clicked();
mouse.accepted = true;

if (mouse.button === Qt.LeftButton && notifyPopup.currentNotify && typeof notifyPopup.currentNotify.activate === "function") {
notifyPopup.currentNotify.activate();
}

dismissTimer.stop();
animateOut.start();
}
}

Column {
id: contentColumn
width: parent.width - 24
anchors.centerIn: parent
spacing: 6

Text {
id: headerText
width: parent.width
color: ThemeEngine.palette.notificationContentColor
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedNotificationHeaderFontSize
font.bold: true
wrapMode: Text.Wrap
horizontalAlignment: Text.AlignHCenter
}

Rectangle {
width: parent.width
height: 1
color: notifyPopup.notifyColor
visible: bodyText.text !== ""
}

Text {
id: bodyText
width: parent.width
color: ThemeEngine.palette.notificationContentColor
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
wrapMode: Text.Wrap
horizontalAlignment: Text.AlignHCenter
}
}
}
}
