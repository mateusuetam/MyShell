pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
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
pam.start();
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
anchors.fill: parent
anchors.margins: 60
spacing: 20

// ==========================================
// LOCK HEADER
// ==========================================
ColumnLayout {
Layout.fillWidth: true
spacing: 5

Text {
text: "MU-TH-UR 6000 // INTERFACE DE SESSÃO SEGURA"
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockLabelFontSize
font.bold: true
color: ThemeEngine.palette.lockLabelColor
}

Rectangle {
Layout.fillWidth: true
implicitHeight: 1
color: ThemeEngine.palette.lockLabelColor
}
}

// ==========================================
// LOCK CLOCK
// ==========================================
ColumnLayout {
Layout.alignment: Qt.AlignHCenter
Layout.topMargin: 40
spacing: 0

Text {
id: clock
property var date: new Date()
Layout.alignment: Qt.AlignHCenter
renderType: Text.NativeRendering
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockClockFontSize
font.bold: true
color: ThemeEngine.palette.lockLabelColor
text: {
const hours = clock.date.getHours().toString().padStart(2, '0');
const minutes = clock.date.getMinutes().toString().padStart(2, '0');
return `${hours}:${minutes}`;
}

Timer {
running: true; repeat: true; interval: 1000
onTriggered: clock.date = new Date()
}
}

Text {
Layout.alignment: Qt.AlignHCenter
text: "SOBREPOSIÇÃO DE HORA DO SISTEMA"
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockLabelFontSize
font.letterSpacing: 4
color: ThemeEngine.palette.lockLabelColor
}
}

Item {
Layout.fillHeight: true
}

// ==========================================
// LOCK PROMPT
// ==========================================
Column {
Layout.alignment: Qt.AlignHCenter
Layout.bottomMargin: 100
spacing: 15

Text {
text: lockRoot.unlockInProgress ? "AUTENTICANDO DIRETÓRIO DE SESSÃO..." : "NOSTROMO_LOGIN_node7 > INSIRA A CHAVE DE ACESSO:"
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockPromptFontSize
color: ThemeEngine.palette.lockPromptLabelColor
}

RowLayout {
spacing: 0

TextField {
id: passwordBox
implicitWidth: 400
padding: 0
focus: true
enabled: !lockRoot.unlockInProgress
echoMode: TextInput.Password
cursorDelegate: Item {}
background: Item {}

font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockInputFontSize
color: ThemeEngine.palette.lockInputLabelColor

onTextChanged: if (lockRoot.showFailure) lockRoot.showFailure = false

onAccepted: lockRoot.tryUnlock(passwordBox.text)

Connections {
target: lockRoot
function onCurrentTextChanged() {
if (lockRoot.currentText === "") {
passwordBox.text = "";
}
}
}
}

Text {
text: "▒"
font.pixelSize: ThemeEngine.appliedLockPromptInputFontSize
color: ThemeEngine.palette.lockInputLabelColor
visible: !lockRoot.unlockInProgress

Timer {
running: true; repeat: true; interval: 600
onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.0 : 1.0
}
}
}

Rectangle {
implicitWidth: 415
implicitHeight: 2
color: ThemeEngine.palette.lockInputLabelColor
}

Text {
anchors.horizontalCenter: parent.horizontalCenter
visible: lockRoot.showFailure
text: "!! ERRO: CHAVE DE ACESSO INVÁLIDA // ACESSO NEGADO !!"
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedLockPromptErrorFontSize
font.bold: true
color: ThemeEngine.palette.lockPromptErrorColor

Timer {
running: lockRoot.showFailure; repeat: true; interval: 400
onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0
}
}
}
}
}
}
}
