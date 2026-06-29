//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "components"
import "components/wallpaper"
import "components/lockscreen"
import "components/popupmenu"

ShellRoot {
id: shellScope

ContextMenu {
id: sharedContextMenu
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

IpcHandler {
target: "start_launcher"
function open(): void {
if (mainBarWindow && mainBarWindow.startModule) {
mainBarWindow.startModule.openAppMenu();
}
}
}

NotificationPopup {
targetWindow: mainBarWindow
globalMenu: sharedContextMenu
}

IdleManager {
id: globalIdle
lockTarget: nativeLock
}

LockScreen {
id: nativeLock
}

IpcHandler {
target: "lock_manager"
function lock(): void {
globalIdle.lockScreen();
}
}
}
