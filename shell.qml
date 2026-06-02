//@ pragma UseQApplication
import QtQuick
import Quickshell
import "components"

ShellRoot {
    id: shellScope

    Wallpaper {
        screen: Quickshell.screens[0]
    }

    MainBar {
        id: mainBarWindow
        screen: Quickshell.screens[0]
    }

    NotificationPopup {
        targetWindow: mainBarWindow
    }

    IdleManager {
        id: globalIdle
        enabled: true
    }
    // LockScreen { visible: algumSinalDeBloqueio }
}
