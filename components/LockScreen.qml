pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../core"

Item {
id: lockRoot

property string currentText: ""
property bool unlockInProgress: false
property bool showFailure: false

function activateLock() {
currentText = "";
showFailure = false;
sessionLock.locked = true;
}

function tryUnlock(password) {
if (password === "") return;
lockRoot.currentText = password;
lockRoot.unlockInProgress = true;
validationDelay.restart();
}

Timer {
id: validationDelay
interval: 300
repeat: false
onTriggered: pam.start()
}

PamContext {
id: pam
configDirectory: "../core"
config: "password.conf"
onPamMessage: if (this.responseRequired) this.respond(lockRoot.currentText)
onCompleted: result => {
if (result === PamResult.Success) {
sessionLock.locked = false;
} else {
lockRoot.currentText = "";
lockRoot.showFailure = true;
}
lockRoot.unlockInProgress = false;
}
}

WlSessionLock {
id: sessionLock

WlSessionLockSurface {
id: lockSurface
color: ThemeEngine.palette.lockScreenBackgroundColor

ColumnLayout {
anchors.centerIn: parent
spacing: 30

Text {
id: clock
Layout.alignment: Qt.AlignHCenter
text: Qt.formatTime(systemClock.date, "HH:mm")
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockClockFontSize
font.bold: true
color: ThemeEngine.palette.lockLabelColor
renderType: Text.NativeRendering
}

ColumnLayout {
Layout.alignment: Qt.AlignHCenter
spacing: 8

TextField {
id: passwordBox
implicitWidth: 320
implicitHeight: 42
focus: true
enabled: !lockRoot.unlockInProgress
echoMode: TextInput.Password
horizontalAlignment: TextInput.AlignHCenter
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockInputFontSize
color: ThemeEngine.palette.lockInputLabelColor
selectionColor: ThemeEngine.palette.lockInputLabelColor
selectedTextColor: ThemeEngine.palette.lockScreenBackgroundColor
padding: 8

cursorDelegate: Rectangle {
width: 1
height: Math.round(passwordBox.font.pixelSize * 1.2)
color: ThemeEngine.palette.lockInputLabelColor
SequentialAnimation on opacity {
running: passwordBox.activeFocus
loops: Animation.Infinite
NumberAnimation {
to: 0
duration: 500
}
NumberAnimation {
to: 1
duration: 500
}
}
}

background: Rectangle {
radius: ThemeEngine.palette.shellRadius
color: ThemeEngine.palette.lockScreenBackgroundColor
border.width: 1
border.color: lockRoot.showFailure ? ThemeEngine.palette.lockPromptErrorColor : ThemeEngine.palette.lockInputLabelColor
opacity: lockRoot.showFailure ? 1.0 : 0.65
}

onTextChanged: if (lockRoot.showFailure) lockRoot.showFailure = false;
onAccepted: lockRoot.tryUnlock(passwordBox.text);

Connections {
target: lockRoot

function onCurrentTextChanged() {
if (lockRoot.currentText === "") passwordBox.text = "";
}
}
}

Rectangle {
Layout.alignment: Qt.AlignHCenter
Layout.preferredWidth: lockRoot.unlockInProgress ? 24 : 0
Layout.preferredHeight: 2
color: ThemeEngine.palette.lockInputLabelColor

Behavior on Layout.preferredWidth {
NumberAnimation {
duration: 150
}
}

SequentialAnimation on opacity {
running: lockRoot.unlockInProgress
loops: Animation.Infinite

NumberAnimation {
to: 0.25
duration: 500
}

NumberAnimation {
to: 1.0
duration: 500
}
}
}

Text {
Layout.alignment: Qt.AlignHCenter
visible: lockRoot.showFailure
text: "SENHA INVÁLIDA"
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockPromptErrorFontSize
font.bold: true
color: ThemeEngine.palette.lockPromptErrorColor
Timer {
running: lockRoot.showFailure
repeat: true
interval: 400
onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0
}
}
}
}
}
}

SystemClock {
id: systemClock
precision: SystemClock.Minutes
}
}
