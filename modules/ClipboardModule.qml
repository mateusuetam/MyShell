import QtQuick
import Quickshell.Io
import "../core"

Item {
id: clipboardModule

required property var globalMenu
required property var parentWindow

implicitWidth: clipboardRow.implicitWidth
implicitHeight: clipboardModule.parentWindow ? clipboardModule.parentWindow.barHeight : 30

property var _tempModel: []

function parseClipboardOutput(rawText) {
let processedModel = [];
let cleanText = String(rawText || "").trim();

if (cleanText === "")
return processedModel;

let lines = cleanText.split("\n");
for (let i = 0; i < lines.length; i++) {
let trimmed = lines[i].trim();
if (trimmed === "")
continue;

let match = trimmed.match(/^(\d+)\s+(.*)$/);
let textPart = (match && match[2]) ? match[2].trim() : trimmed;

processedModel.push({
text: textPart,
display: textPart,
value: trimmed,
onTrigger: () => {
clipboardModule.handleClipboardSelection(trimmed);
}
});
}
return processedModel;
}

function refreshClipboardList() {
cliphistListProcess.running = false;
cliphistListProcess.running = true;
}

function clearClipboardHistory() {
cliphistAction.command = ["sh", "-c", "cliphist wipe && notify-send -u low Clipboard 'Histórico apagado!'"];
cliphistAction.startDetached();
}

Process {
id: cliphistListProcess
command: ["sh", "-c", "cliphist list | head -n 50"]

stdout: StdioCollector {
id: clipboardBuffer

onStreamFinished: {
clipboardModule._tempModel = clipboardModule.parseClipboardOutput(this.text);

if (clipboardModule._tempModel.length > 0 && clipboardModule.globalMenu) {
clipboardModule.globalMenu.showSearchInput = true;
clipboardModule.globalMenu.openMenu(clipboardModule.parentWindow, clipboardModule, clipboardModule._tempModel);
}
}
}
}

Process {
id: cliphistAction
}

function handleClipboardSelection(stringData) {
if (stringData && typeof stringData === 'string') {
cliphistAction.command = ["sh", "-c", "printf '%s\n' " + utils.escapeShell(stringData) + " | cliphist decode | wl-copy"];
cliphistAction.startDetached();
}
}

QtObject {
id: utils
function escapeShell(cmd) {
return "'" + cmd.replace(/'/g, "'\\''") + "'";
}
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: mouse => {
let menu = clipboardModule.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
clipboardModule.refreshClipboardList();
} else if (mouse.button === Qt.RightButton) {
clipboardModule.clearClipboardHistory();
}
}
}

Row {
id: clipboardRow
anchors.verticalCenter: parent.verticalCenter
Text {
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
color: ThemeRegistry.clipboardLabelColor
text: "CLIP"
}
}
}
