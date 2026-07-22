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
color: ThemeRegistry.lockScreenBackgroundColor

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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 14
font.bold: true
color: ThemeRegistry.lockLabelColor
}

Rectangle {
Layout.fillWidth: true
implicitHeight: 1
color: ThemeRegistry.lockLabelColor
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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 110
font.bold: true
color: ThemeRegistry.lockLabelColor
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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 12
font.letterSpacing: 4
color: ThemeRegistry.lockLabelColor
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
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 16
color: ThemeRegistry.lockPromptLabelColor
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

font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 22
color: ThemeRegistry.lockPromptInputActiveColor

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
font.pixelSize: 22
color: ThemeRegistry.lockPromptInputActiveColor
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
color: ThemeRegistry.lockPromptInputActiveColor
}

Text {
anchors.horizontalCenter: parent.horizontalCenter
visible: lockRoot.showFailure
text: "!! ERRO: CHAVE DE ACESSO INVÁLIDA // ACESSO NEGADO !!"
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: 14
font.bold: true
color: ThemeRegistry.lockPromptErrorColor

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
