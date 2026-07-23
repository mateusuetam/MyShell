pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../core"

PopupWindow {
id: notifyPopup

readonly property int cardWidth: 350
readonly property int contentPadding: 25

readonly property int verticalMargin: 10
readonly property int horizontalMargin: 10

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

required property var targetWindow
readonly property var currentScreen: targetWindow?.screen ?? (Quickshell.screens[0] ?? null)

Binding {
target: ThemeEngine
property: "dynamicBorderColor"
value: notifyPopup.notifyColor
}

anchor.window: targetWindow
anchor.rect.y: targetWindow ? (targetWindow.height + verticalMargin) : 0
anchor.rect.x: currentScreen ? (currentScreen.width - implicitWidth) : 0
implicitWidth: cardWidth + horizontalMargin
implicitHeight: contentColumn.implicitHeight + 20

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

if (headerText.text !== currentNotify.summary)
headerText.text = currentNotify.summary;

if (bodyText.text !== currentNotify.body)
bodyText.text = currentNotify.body;

notifyPopup.visible = true;
animateIn.start();

let timeout = 4000;
if (currentNotify.expireTimeout > 0) {
timeout = currentNotify.expireTimeout * 1000;
} else if (currentNotify.urgency === NotificationUrgency.Critical) {
timeout = 8000;
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
property: "x"
from: notifyPopup.width
to: 0
duration: 350
easing.type: Easing.OutCubic
}

NumberAnimation {
id: animateOut
target: visualBox
property: "x"
from: 0
to: notifyPopup.width
duration: 300
easing.type: Easing.InCubic
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
width: notifyPopup.cardWidth
height: parent.height
x: parent.width

color: ThemeEngine.palette.backgroundColor
border.color: ThemeEngine.dynamicBorderColor
border.width: 1
radius: ThemeEngine.palette.shellRadius

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
if (!animateOut.running)
animateOut.start();
}
}

Column {
id: contentColumn
width: parent.width - notifyPopup.contentPadding
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
color: ThemeEngine.dynamicBorderColor
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
