pragma Singleton
import QtQuick
import QtCore
import Quickshell
import "./Palettes"

QtObject {
id: themeEngine

property var palette: GruvboxDark
property string currentTheme: defaultTheme

readonly property string defaultTheme: "GruvboxDark"

readonly property var palettes: ({
GruvboxDark: GruvboxDark,
CatppuccinMocha: CatppuccinMocha
})

readonly property var availableThemes: Object.keys(palettes)

readonly property var menuStructure: availableThemes.map(tName => ({
type: "action",
text: tName,
enabled: true,
preventClose: false,
onTrigger: () => themeEngine.changeTheme(tName)
}))

property string savedTheme: defaultTheme

property var themeSettings: Settings {
location: ConfigPaths.themeConfig
category: "Theme"
property alias savedTheme: themeEngine.savedTheme
}

Component.onCompleted: {
Qt.application.name = "Quickshell";

if (savedTheme !== "" && hasTheme(savedTheme)) {
changeTheme(savedTheme);
} else {
changeTheme(defaultTheme);
}
}

function sendNotification(summary, body, urgency = "normal") {
Quickshell.execDetached(["notify-send", "-u", urgency, summary, body]);
}

function hasTheme(themeName) {
return palettes.hasOwnProperty(themeName);
}

function changeTheme(themeName) {
var selectedPalette = palettes[themeName];

if (!selectedPalette) {
sendNotification("Theme Engine", "Falha ao trocar de tema: " + themeName, "critical");
return false;
}

if (selectedPalette === palette) {
return true;
}

currentTheme = themeName;
palette = selectedPalette;
savedTheme = themeName;

sendNotification("Theme Engine", "Tema aplicado: " + themeName, "normal");
return true;
}
}
