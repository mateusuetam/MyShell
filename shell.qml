//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import "components"
import "components/wallpaper"
import "components/lockscreen"
import "components/contextmenu"

ShellRoot {
    id: shellScope

    ContextMenu {
        id: sharedContextMenu
    }

    IpcHandler {
        target: "lock_manager"
        function lock(): void {
            globalIdle.lockScreen();
        }
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

    NotificationPopup {
        targetWindow: mainBarWindow
    }

    IdleManager {
        id: globalIdle
        lockTarget: nativeLock
    }

    LockScreen {
        id: nativeLock
    }
}
