pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtCore
import Quickshell
import "./Palettes"

QtObject {
id: themeEngine

property var palette: GruvboxDark
property string currentTheme: defaultTheme
readonly property string defaultTheme: "GruvboxDark"

readonly property string appliedFontFamily: "Monaspace Krypton NF"
readonly property int appliedSplashTitleFontSize: 30
readonly property int appliedSplashStartFontSize: 20
readonly property int appliedSplashLabelFontSize: 18
readonly property int appliedFontSize: 14
readonly property int appliedMenuFontSize: 12
readonly property int appliedNotificationHeaderFontSize: 16
readonly property int appliedLockLabelFontSize: 14
readonly property int appliedLockClockFontSize: 110
readonly property int appliedLockPromptFontSize: 16
readonly property int appliedLockInputFontSize: 22
readonly property int appliedLockPromptInputFontSize: 22
readonly property int appliedLockPromptErrorFontSize: 14

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
location: `file://${Quickshell.env("HOME")}/.local/share/MyShell/theme.conf`
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
