//@ pragma UseQApplication
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "components"

ShellRoot {
id: shellScope

LoadingWindow {
screen: Quickshell.screens[0]
}

Wallpaper {
id: shellWallpaper
screen: Quickshell.screens[0]
}

ContextMenu {
id: sharedContextMenu
}

MainBar {
id: mainBarWindow
screen: Quickshell.screens[0]
globalMenu: sharedContextMenu
startModule.wallpaperMenuStructure: shellWallpaper.menuStructure
startModule.onWallpaperChangeRequested: function(path) {
shellWallpaper.requestWallpaperChange(path)
}
}

NotificationPopup {
targetWindow: mainBarWindow
onClicked: sharedContextMenu.close()
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
