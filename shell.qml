//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "components"

ShellRoot {
id: shellScope

ContextMenu {
id: sharedContextMenu
}

NotificationPopup {
targetWindow: mainBarWindow
onClicked: sharedContextMenu.close()
}

Wallpaper {
screen: Quickshell.screens[0]
globalMenu: sharedContextMenu
}

MainBar {
id: mainBarWindow
screen: Quickshell.screens[0]
globalMenu: sharedContextMenu
}

LockScreen {
id: nativeLock
}

IdleManager {
id: globalIdle
lockTarget: nativeLock
}

IpcHandler {
target: "start_launcher"
function open(): void {
if (mainBarWindow && mainBarWindow.startModule) {
mainBarWindow.startModule.openAppMenu();
}
}
}

IpcHandler {
target: "lock_manager"
function lock(): void {
globalIdle.lockScreen();
}
}
}
