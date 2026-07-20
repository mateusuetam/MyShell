pragma Singleton
import QtQuick
import Quickshell

QtObject {
id: configPaths

readonly property string baseDir: `file://${Quickshell.env("HOME")}/.local/share/MyShell`

readonly property string themeConfig: `${baseDir}/theme.conf`
readonly property string wallpaperConfig: `${baseDir}/wallpaper.conf`
}
