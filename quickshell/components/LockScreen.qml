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
property int pamPromptCount: 0
signal clearPasswordRequested()

function clearPassword() {
currentText = "";
clearPasswordRequested();
}

function failUnlock() {
clearPassword();
unlockInProgress = false;
showFailure = true;
}

function activateLock() {
validationDelay.stop();
if (pam.active) pam.abort();
clearPassword();
unlockInProgress = false;
showFailure = false;
sessionLock.locked = true;
}

function tryUnlock(password) {
if (password === "" || unlockInProgress || pam.active || !sessionLock.secure) return;
currentText = password;
showFailure = false;
unlockInProgress = true;
pamPromptCount = 0;
validationDelay.restart();
}

Timer {
id: validationDelay
interval: 300
repeat: false
onTriggered: {
if (!lockRoot.unlockInProgress) return;
if (!sessionLock.secure) {
lockRoot.failUnlock();
return;
}
if (!pam.start()) lockRoot.failUnlock();
}
}

PamContext {
id: pam
configDirectory: "../core"
config: "password.conf"
onPamMessage: {
if (!pam.responseRequired) return;
if (pam.responseVisible || lockRoot.pamPromptCount >= 1 || lockRoot.currentText === "") {
pam.abort();
lockRoot.failUnlock();
return;
}
lockRoot.pamPromptCount++;
pam.respond(lockRoot.currentText);
}
onCompleted: result => {
if (!lockRoot.unlockInProgress) return;
if (result === PamResult.Success && sessionLock.secure) {
lockRoot.clearPassword();
lockRoot.unlockInProgress = false;
sessionLock.locked = false;
} else {
lockRoot.failUnlock();
}
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
color: ThemeEngine.palette.lockTextColor
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
enabled: sessionLock.secure && !lockRoot.unlockInProgress
echoMode: TextInput.Password
horizontalAlignment: TextInput.AlignHCenter
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockInputFontSize
color: ThemeEngine.palette.lockTextColor
selectionColor: ThemeEngine.palette.lockTextColor
selectedTextColor: ThemeEngine.palette.lockScreenBackgroundColor
padding: 8

cursorDelegate: Rectangle {
width: 1
height: Math.round(passwordBox.font.pixelSize * 1.2)
color: ThemeEngine.palette.lockTextColor
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
border.width: 2
border.color: lockRoot.showFailure ? ThemeEngine.palette.lockErrorColor : ThemeEngine.palette.lockInputBorderColor
opacity: lockRoot.showFailure ? 1.0 : 0.65
}

onTextChanged: {
if (lockRoot.showFailure) lockRoot.showFailure = false;
}
onAccepted: {
lockRoot.tryUnlock(passwordBox.text);
}

Connections {
target: lockRoot
function onClearPasswordRequested() {
passwordBox.text = "";
}
}
}

Rectangle {
Layout.alignment: Qt.AlignHCenter
Layout.preferredWidth: lockRoot.unlockInProgress ? 24 : 0
Layout.preferredHeight: 2
color: ThemeEngine.palette.lockTextColor

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
font.pixelSize: ThemeEngine.appliedLockErrorFontSize
font.bold: true
color: ThemeEngine.palette.lockErrorColor
Timer {
running: lockRoot.showFailure
repeat: true
interval: 400
onTriggered: {
parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0;
}
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
