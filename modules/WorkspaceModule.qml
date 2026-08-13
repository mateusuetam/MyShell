pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../core"

RowLayout {
id: root

property var parentWindow
property var globalMenu

property var workspaces: []
property var focusedId: null

readonly property string niriSocketPath: Quickshell.env("NIRI_SOCKET") || ""

property int eventReconnectDelay: 250
property int actionReconnectDelay: 250
readonly property int maxReconnectDelay: 5000

property string pendingAction: ""

spacing: 5

function sendNiriAction(action) {
if (root.niriSocketPath === "") return;

if (niriActionSocket.connected) {
niriActionSocket.write(action + "\n");
niriActionSocket.flush();
return;
}

root.pendingAction = action;
niriActionSocket.connected = true;
}

Socket {
id: niriEventSocket

path: root.niriSocketPath
connected: root.niriSocketPath !== ""

parser: SplitParser {
splitMarker: "\n"

onRead: message => {
const line = message.trim();

if (line === "") return;

const isWorkspacesChanged = line.startsWith('{"WorkspacesChanged":');
const isWorkspaceActivated = line.startsWith('{"WorkspaceActivated":');

if (!isWorkspacesChanged && !isWorkspaceActivated) return;

try {
const event = JSON.parse(line);

if (isWorkspacesChanged) {
const source = event.WorkspacesChanged.workspaces;
let nextFocusedId = null;
let modelChanged = source.length !== root.workspaces.length;

if (!modelChanged) {
for (let i = 0; i < source.length; i++) {
const workspace = source[i];
const current = root.workspaces[i];

if (current.id !== String(workspace.id) || current.idx !== workspace.idx) {
modelChanged = true;
break;
}
}
}

if (modelChanged) {
const nextWorkspaces = new Array(source.length);

for (let i = 0; i < source.length; i++) {
const workspace = source[i];
const id = String(workspace.id);

nextWorkspaces[i] = {id: id, idx: workspace.idx};

if (workspace.is_focused) nextFocusedId = id;
}

root.workspaces = nextWorkspaces;
} else {
for (let i = 0; i < source.length; i++) {
if (source[i].is_focused) {
nextFocusedId = String(source[i].id);
break;
}
}
}

if (root.focusedId !== nextFocusedId) root.focusedId = nextFocusedId;
} else {
const activation = event.WorkspaceActivated;

if (activation.focused) {
const id = String(activation.id);

if (root.focusedId !== id) root.focusedId = id;
}
}
}
catch (error) {
console.error("WorkspaceModule: Falha ao parsear evento do Niri:", error);
}
}
}

onConnectedChanged: {
if (connected) {
root.eventReconnectDelay = 250;
write('"EventStream"\n');
flush();
} else if (root.niriSocketPath !== "") {
eventReconnectTimer.interval = root.eventReconnectDelay;
eventReconnectTimer.restart();
root.eventReconnectDelay = Math.min(root.eventReconnectDelay * 2, root.maxReconnectDelay);
}
}
}

Timer {
id: eventReconnectTimer

repeat: false
interval: 250

onTriggered: {
if (!niriEventSocket.connected && root.niriSocketPath !== "") niriEventSocket.connected = true;
}
}

Socket {
id: niriActionSocket

path: root.niriSocketPath
connected: root.niriSocketPath !== ""

parser: SplitParser {
splitMarker: "\n"
onRead: message => {}
}

onConnectedChanged: {
if (connected) {
root.actionReconnectDelay = 250;

if (root.pendingAction !== "") {
write(root.pendingAction + "\n");
flush();
root.pendingAction = "";
}
} else if (root.niriSocketPath !== "") {
actionReconnectTimer.interval = root.actionReconnectDelay;
actionReconnectTimer.restart();
root.actionReconnectDelay = Math.min(root.actionReconnectDelay * 2, root.maxReconnectDelay);
}
}
}

Timer {
id: actionReconnectTimer

repeat: false
interval: 250

onTriggered: {
if (!niriActionSocket.connected && root.niriSocketPath !== "") niriActionSocket.connected = true;
}
}

Repeater {
model: ScriptModel {
objectProp: "id"
values: root.workspaces
}

Rectangle {
id: wsDot

required property var modelData
property bool isFocused: root.focusedId === modelData.id

implicitWidth: isFocused ? 24 : 12
implicitHeight: 12

radius: ThemeEngine.palette.shellRadius

color: isFocused ? ThemeEngine.dynamicBorderColor : "transparent"

border.color: ThemeEngine.dynamicBorderColor
border.width: 1

Behavior on implicitWidth {
NumberAnimation {
duration: 150
easing.type: Easing.OutQuad
}
}

MouseArea {
anchors.fill: parent
cursorShape: Qt.PointingHandCursor
onPressed: mouse => {
let menu = root.globalMenu;
if (menu) {
menu.close();
}
mouse.accepted = true;
if (mouse.button === Qt.LeftButton) {
root.sendNiriAction(JSON.stringify({
Action: { FocusWorkspace: { reference: { Index: wsDot.modelData.idx } } }
}));
}
}
}
}
}
}
