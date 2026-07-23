pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import QtCore
import Qt.labs.folderlistmodel
import Quickshell

Item {
id: engine

property alias currentWallpaper: wallpaperSettings.savedPath
property var menuStructure: []

signal transitionRequested(string path)

Settings {
id: wallpaperSettings
location: ConfigPaths.wallpaperConfig
category: "Wallpaper"
property url savedPath: ""
}

FolderListModel {
id: folderModel
folder: `file://${Quickshell.env("HOME")}/Imagens`
nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
showDirs: false
showDotAndDotDot: false
showOnlyReadable: true
onCountChanged: rebuildDebounce.restart()
}

Timer {
id: rebuildDebounce
interval: 100
repeat: false
onTriggered: engine.rebuildMenu()
}

function rebuildMenu() {
let list = [];
const maxItems = Math.min(folderModel.count, 500);

for (let i = 0; i < maxItems; i++) {
const path = folderModel.get(i, "fileUrl");
const name = folderModel.get(i, "fileName");

list.push({
type: "action",
text: name,
path: path,
preventClose: false
});
}
engine.menuStructure = list;
}

function requestWallpaperChange(path) {
engine.transitionRequested(path);
}

function changeWallpaper(path) {
wallpaperSettings.savedPath = path;
}
}
