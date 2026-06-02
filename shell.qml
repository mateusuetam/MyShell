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
        screen: Quickshell.screens[0]
    }

    // NotificationCenter {}
    // LockScreen { visible: algumSinalDeBloqueio }
}
