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
id: normalWallpaper
screen: Quickshell.screens[0]
globalMenu: sharedContextMenu
}

OverviewWallpaper {
id: overviewWallpaper
screen: Quickshell.screens[0]
wallpaperPath: normalWallpaper.currentWallpaperPath
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
