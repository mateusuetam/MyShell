//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "components"
import "core"

ShellRoot {
id: shellScope

SplashManager {
screen: Quickshell.screens[0]
}

ContextMenu {
id: sharedContextMenu
}

MainBar {
id: mainBarWindow
screen: Quickshell.screens[0]
globalMenu: sharedContextMenu
}

NotificationPopup {
targetWindow: mainBarWindow
onClicked: sharedContextMenu.close()
}

Wallpaper {
screen: Quickshell.screens[0]
wallpaperPath: WallpaperEngine.currentWallpaper
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
