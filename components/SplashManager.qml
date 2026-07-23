pragma ComponentBehavior: Bound
import QtQuick
import "../core"

Item {
id: splashManager

required property var screen

Component {
id: splashFactory
SplashWindow {}
}

function spawnSplash(mode, newWallpaper) {
let splash = splashFactory.createObject(splashManager, {
screen: splashManager.screen,
mode: mode,
nextWallpaper: newWallpaper || ""
});
}

Component.onCompleted: spawnSplash("boot", "")

Connections {
target: WallpaperEngine
function onTransitionRequested(path) {
splashManager.spawnSplash("wallpaper", path);
}
}
}
