//@ pragma UseQApplication
import QtQuick
import Quickshell
import "components"

ShellRoot {
    id: shellScope

    MainBar {
        screen: Quickshell.screens[0]
    }

    // Wallpaper { screen: Quickshell.screens[0] }
    // NotificationCenter {}
    // LockScreen { visible: algumSinalDeBloqueio }
}
