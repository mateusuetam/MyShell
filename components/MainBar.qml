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
readonly property int layoutSpacing: 8
readonly property int sideMargins: 5

WlrLayershell.layer: WlrLayer.Top
WlrLayershell.namespace: "mainbar"

anchors {
top: true
right: true
left: true
}

implicitHeight: barWindow.barHeight
exclusionMode: ExclusionMode.Auto
WlrLayershell.keyboardFocus: ((barWindow.globalMenu && barWindow.globalMenu.isMenuFocused && barWindow.globalMenu._pendingWindow === barWindow) ||
(wifiPasswordPromptInstance && wifiPasswordPromptInstance.visible))
? WlrKeyboardFocus.OnDemand
: WlrKeyboardFocus.None

PasswordPrompt { id: wifiPasswordPromptInstance }

// --- SEPARADOR ---
component Separator: Item {
implicitWidth: 4
Layout.fillHeight: true
Rectangle {
anchors.centerIn: parent
width: 1
height: Math.round(parent.height * 0.5)
color: ThemeEngine.dynamicBorderColor
opacity: 0.7
}
}

// --- RENDERIZAÇÃO DA BARRA ---
Rectangle {
anchors.fill: parent
color: ThemeEngine.palette.backgroundColor
Rectangle {
anchors.right: parent.right
anchors.bottom: parent.bottom
anchors.left: parent.left
height: 1
color: ThemeEngine.dynamicBorderColor
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
Separator {}
MprisModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }

// <<< ESPAÇADOR >>>
Item {
Layout.fillWidth: true
}

// >>> LADO DIREITO >>>
TrayModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
IdleModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
ClipboardModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
MicrophoneModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
VolumeModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
BluetoothModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
NetworkModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu; passwordPrompt: wifiPasswordPromptInstance }
Separator {}
BacklightModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
BatteryModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
Separator {}
ClockModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
}
}
}
