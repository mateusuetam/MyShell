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

required property var targetWindow
readonly property var currentScreen: targetWindow?.screen ?? (Quickshell.screens[0] ?? null)

visible: notifyModel.count > 0
color: "transparent"

anchor.window: targetWindow
anchor.rect.y: targetWindow ? (targetWindow.height + verticalMargin) : 0
anchor.rect.x: currentScreen ? (currentScreen.width - implicitWidth) : 0
implicitWidth: cardWidth + horizontalMargin

implicitHeight: listView.contentHeight

property var notifMap: ({})
property int nextNotifId: 0

readonly property color notifyColor: {
if (notifyModel.count === 0) {
return ThemeEngine.palette.borderColor;
}
let topUrgency = notifyModel.get(0).urgencyLevel;

switch (topUrgency) {
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

Binding {
target: ThemeEngine
property: "dynamicBorderColor"
value: notifyPopup.notifyColor
}

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
notifyPopup.addNotification(notification);
}
}

ListModel {
id: notifyModel
}

function addNotification(n) {
n.tracked = true;

let timeout = 4000;
if (n.expireTimeout > 0) {
timeout = n.expireTimeout * 1000;
} else if (n.urgency === NotificationUrgency.Critical) {
timeout = 8000;
} else if (n.urgency === NotificationUrgency.Low) {
timeout = 2000;
}

let currentId = nextNotifId++;
notifMap[currentId] = n;

let borderColor = ThemeEngine.palette.borderColor;
if (n.urgency === NotificationUrgency.Low) {
borderColor = ThemeEngine.palette.borderLowColor;
} else if (n.urgency === NotificationUrgency.Normal) {
borderColor = ThemeEngine.palette.borderNormalColor;
} else if (n.urgency === NotificationUrgency.Critical) {
borderColor = ThemeEngine.palette.borderCriticalColor;
}

notifyModel.append({
"notifId": currentId,
"summaryText": n.summary,
"bodyText": n.body,
"urgencyLevel": n.urgency,
"timeoutMs": timeout,
"resolvedBorderColor": borderColor
});
}

ListView {
id: listView
width: notifyPopup.cardWidth
height: contentHeight

interactive: false
spacing: 10
clip: false

model: notifyModel

add: Transition {
NumberAnimation { property: "x"; from: notifyPopup.width; to: 0; duration: 350; easing.type: Easing.OutCubic }
}

delegate: Rectangle {
id: delegateCard

required property int index
required property int notifId
required property string summaryText
required property string bodyText
required property int urgencyLevel
required property int timeoutMs
required property color resolvedBorderColor

property bool isClosing: false

width: listView.width
implicitHeight: Math.ceil(contentColumn.implicitHeight + (notifyPopup.contentPadding * 1.5))

color: ThemeEngine.palette.backgroundColor
border.width: 1
radius: ThemeEngine.palette.shellRadius

border.color: delegateCard.resolvedBorderColor

NumberAnimation {
id: slideOutAnim
target: delegateCard
property: "x"
to: notifyPopup.width
duration: 400
easing.type: Easing.InCubic
onFinished: delegateCard.finalizeRemoval()
}

Timer {
id: dismissTimer
running: true
interval: delegateCard.timeoutMs
onTriggered: delegateCard.requestClose()
}

function requestClose() {
if (delegateCard.isClosing) return;
delegateCard.isClosing = true;
dismissTimer.stop();
slideOutAnim.start();
}

function finalizeRemoval() {
let n = notifyPopup.notifMap[notifId];
if (n && typeof n.dismiss === "function") {
n.dismiss();
}
delete notifyPopup.notifMap[notifId];

let currentIdx = delegateCard.index;
if (currentIdx >= 0 && currentIdx < notifyModel.count && notifyModel.get(currentIdx).notifId === notifId) {
notifyModel.remove(currentIdx);
}
else {
for (let i = 0; i < notifyModel.count; i++) {
if (notifyModel.get(i).notifId === notifId) {
notifyModel.remove(i);
break;
}
}
}
}

MouseArea {
anchors.fill: parent
hoverEnabled: true
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onEntered: {
dismissTimer.stop();
}

onExited: {
dismissTimer.restart();
}

onPressed: mouse => {
notifyPopup.clicked();
mouse.accepted = true;

let n = notifyPopup.notifMap[delegateCard.notifId];

if (mouse.button === Qt.LeftButton && n && typeof n.activate === "function") {
n.activate();
}
delegateCard.requestClose();
}
}

Column {
id: contentColumn
width: parent.width - notifyPopup.contentPadding
anchors.centerIn: parent
spacing: 6

Text {
id: headerLabel
text: delegateCard.summaryText
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
color: delegateCard.border.color
visible: bodyLabel.text !== ""
}

Text {
id: bodyLabel
text: delegateCard.bodyText
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
}
