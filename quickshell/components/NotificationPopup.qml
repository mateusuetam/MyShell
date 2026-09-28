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

color: "transparent"

ListModel {
id: notifyModel
}

property alias notificationModel: notifyModel

visible: notifyPopup.notificationModel.count > 0

anchor.window: targetWindow
anchor.rect.y: targetWindow ? (targetWindow.height + verticalMargin) : 0
anchor.rect.x: currentScreen ? (currentScreen.width - implicitWidth) : 0

implicitWidth: cardWidth + horizontalMargin
implicitHeight: listView.contentHeight

property var notifMap: ({})
property int nextNotifId: 0

readonly property color notifyColor: notifyPopup.notificationModel.count > 0 ? notifyPopup.urgencyBorderColor(notifyPopup.notificationModel.get(0).urgencyLevel) : ThemeEngine.palette.borderColor

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
notifyPopup.addNotification(notification)
}
}

function urgencyBorderColor(urgency) {
switch (urgency) {
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

function notificationTimeout(n) {
if (n.urgency === NotificationUrgency.Critical) return 0;
if (n.expireTimeout > 0) return n.expireTimeout * 1000;
return n.urgency === NotificationUrgency.Low ? 2000 : 4000;
}

function addNotification(n) {
n.tracked = true;

const currentId = nextNotifId++;
notifMap[currentId] = n;

notifyPopup.notificationModel.append({
notifId: currentId,
summaryText: n.summary,
bodyText: n.body,
urgencyLevel: n.urgency,
timeoutMs: notifyPopup.notificationTimeout(n),
resolvedBorderColor:
notifyPopup.urgencyBorderColor(n.urgency)
});
}

ListView {
id: listView

width: notifyPopup.cardWidth
height: contentHeight

interactive: false
spacing: 10
clip: false

model: notifyPopup.notificationModel

add: Transition {
NumberAnimation {
property: "x"
from: notifyPopup.width
to: 0
duration: 350
easing.type: Easing.OutCubic
}
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
interval: delegateCard.timeoutMs
running: interval > 0
onTriggered: delegateCard.requestClose()
}

function requestClose() {
if (delegateCard.isClosing) return;
delegateCard.isClosing = true;
dismissTimer.stop();
slideOutAnim.start();
}

function finalizeRemoval() {
const n = notifyPopup.notifMap[delegateCard.notifId];

if (n && typeof n.dismiss === "function") n.dismiss();

delete notifyPopup.notifMap[delegateCard.notifId];

const currentIdx = delegateCard.index;
const model = notifyPopup.notificationModel;

if (
currentIdx >= 0 &&
currentIdx < model.count &&
model.get(currentIdx).notifId === delegateCard.notifId
) {
model.remove(currentIdx);
return;
}

for (let i = 0; i < model.count; i++) {
if (model.get(i).notifId === delegateCard.notifId) {
model.remove(i);
break;
}
}
}

MouseArea {
anchors.fill: parent
hoverEnabled: true
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton

onEntered: dismissTimer.stop()

onExited: {
if (dismissTimer.interval > 0)
dismissTimer.restart()
}

onPressed: mouse => {
mouse.accepted = true;
notifyPopup.clicked();

const n = notifyPopup.notifMap[delegateCard.notifId];

if (
mouse.button === Qt.LeftButton && n && typeof n.activate === "function"
) {
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
