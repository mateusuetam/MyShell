pragma Singleton
pragma ComponentBehavior: Bound
import QtQml

QtObject {
property var contextMenu: null
property var textPrompt: null

function claimContextMenu() {
if (textPrompt && textPrompt.visible) textPrompt.closeImmediate();
}

function claimTextPrompt() {
if (contextMenu && (contextMenu.visible || contextMenu.isClosing || contextMenu._isPreparing)) contextMenu.closeImmediate();
}
}
