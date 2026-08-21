pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core"

PopupWindow {
id: textPopup

property var targetWindow: null
property string statusState: "input"
property string promptMessage: ""
readonly property string defaultErrorMessage: "Tente novamente:"
property string errorMessage: defaultErrorMessage
property string processingMessage: "Processando..."
property bool isPasswordMode: false
property var acceptCallback: null

color: "transparent"

implicitWidth: 440
implicitHeight: 40
grabFocus: true

onVisibleChanged: {
if (visible) {
textPopup.statusState = "input";
inputField.text = "";
Qt.callLater(() => {
inputField.forceActiveFocus();
});
} else {
textPopup.acceptCallback = null;
}
}

function _dyn(obj) { return obj; }

function openPrompt(message, parentWin, isPassword, onAccept, processingMsg = "Processando...") {
if (!parentWin) return;

textPopup.promptMessage = message;
textPopup.processingMessage = processingMsg;
textPopup.errorMessage = textPopup.defaultErrorMessage;
textPopup.targetWindow = parentWin;
textPopup.isPasswordMode = isPassword;
textPopup.acceptCallback = onAccept;

let pX = (parentWin.width / 2) - (textPopup.implicitWidth / 2);
let pY = parentWin.height + 6;

textPopup._dyn(textPopup).anchor.window = parentWin;
textPopup._dyn(textPopup).anchor.rect = Qt.rect(pX, pY, 1, 1);

textPopup.visible = true;
}

function showError(msg) {
textPopup.statusState = "error";
textPopup.errorMessage = msg ?? textPopup.defaultErrorMessage;
inputField.text = "";
inputField.forceActiveFocus();
}

function closePrompt() {
textPopup.visible = false;
}

Rectangle {
anchors.fill: parent
color: ThemeEngine.palette.backgroundColor
border.color: textPopup.statusState === "error" ? ThemeEngine.palette.menuErrorColor : ThemeEngine.dynamicBorderColor
border.width: 1
radius: ThemeEngine.palette.shellRadius

RowLayout {
anchors.fill: parent
anchors.margins: 8
spacing: 10

Text {
id: promptLabel
Layout.alignment: Qt.AlignVCenter
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: textPopup.statusState === "error" ? ThemeEngine.palette.menuErrorColor : ThemeEngine.palette.menuTextColor

text: {
if (textPopup.statusState === "error") return textPopup.errorMessage;
if (textPopup.statusState === "processing") return textPopup.processingMessage;
return textPopup.promptMessage;
}
}

TextInput {
id: inputField
Layout.alignment: Qt.AlignVCenter
Layout.fillWidth: true
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedFontSize
color: ThemeEngine.palette.menuTextColor
echoMode: textPopup.isPasswordMode ? TextInput.Password : TextInput.Normal
selectByMouse: true
clip: true
visible: textPopup.statusState !== "processing"

Keys.onPressed: event => {
if (event.key === Qt.Key_Escape) {
textPopup.closePrompt();
event.accepted = true;
} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
if (inputField.text.length > 0) {
textPopup.statusState = "processing";
if (textPopup.acceptCallback) {
textPopup.acceptCallback(inputField.text);
} else {
textPopup.closePrompt();
}
} else {
textPopup.closePrompt();
}
event.accepted = true;
}
}
}
}
}
}
