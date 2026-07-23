pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../core"
import "../modules"

PanelWindow {
id: barWindow

property var globalMenu: null
property alias startModule: startModuleInstance

readonly property int barHeight: 30
readonly property int layoutSpacing: 10
readonly property int sideMargins: 5

WlrLayershell.layer: WlrLayer.Top
WlrLayershell.namespace: "mainbar"

anchors {
top: true
left: true
right: true
}

implicitHeight: barWindow.barHeight
exclusionMode: ExclusionMode.Auto
WlrLayershell.keyboardFocus: ((barWindow.globalMenu && barWindow.globalMenu.isMenuFocused && barWindow.globalMenu._pendingWindow === barWindow) ||
(wifiPasswordPromptInstance && wifiPasswordPromptInstance.visible))
? WlrKeyboardFocus.OnDemand
: WlrKeyboardFocus.None

PasswordPrompt { id: wifiPasswordPromptInstance }

// --- RENDERIZAÇÃO DA BARRA ---
Rectangle {
anchors.fill: parent
color: ThemeEngine.palette.backgroundColor

Rectangle {
anchors.bottom: parent.bottom
anchors.left: parent.left
anchors.right: parent.right
height: 1
color: ThemeEngine.palette.dynamicBorderColor

Behavior on color {
ColorAnimation {
duration: 200
}
}
}

MouseArea {
anchors.fill: parent
acceptedButtons: Qt.LeftButton | Qt.RightButton
onPressed: {
if (barWindow.globalMenu) {
barWindow.globalMenu.close();
}
}
}

RowLayout {
anchors.fill: parent
anchors.leftMargin: barWindow.sideMargins
anchors.rightMargin: barWindow.sideMargins
spacing: barWindow.layoutSpacing
z: 1

// <<< LADO ESQUERDO <<<
StartModule { id: startModuleInstance; parentWindow: barWindow; globalMenu: barWindow.globalMenu }
MprisModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }

// <<< ESPAÇADOR >>>
Item {
Layout.fillWidth: true
}

// >>> LADO DIREITO >>>
TrayModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
IdleModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
ClipboardModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
MicrophoneModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
VolumeModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
BluetoothModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
NetworkModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu; passwordPrompt: wifiPasswordPromptInstance }
BacklightModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
BatteryModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
ClockModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
}
}
}
