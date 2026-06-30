import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../modules"
import "themeengine"

PanelWindow {
id: barWindow

property var globalMenu: null
property alias startModule: startModuleInstance

property color barBorderColor: ThemeRegistry.mainbarBorderColor

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
exclusiveZone: barWindow.barHeight
WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

// --- RENDERIZAÇÃO DA BARRA ---
Rectangle {
anchors.fill: parent
color: ThemeRegistry.mainbarBackgroundColor

Rectangle {
anchors.bottom: parent.bottom
anchors.left: parent.left
anchors.right: parent.right
height: 1
color: barWindow.barBorderColor

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
spacing: 0
z: 1

// <<< LADO ESQUERDO <<<
MprisModule {
Layout.fillHeight: true
Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
parentWindow: barWindow
globalMenu: barWindow.globalMenu
}

Item {
Layout.fillWidth: true
}

// >>> LADO DIREITO >>>
Row {
id: rightModules
Layout.fillHeight: true
spacing: barWindow.layoutSpacing
Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

TrayModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
IdleModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
ClipboardModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
MicrophoneModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
VolumeModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
BluetoothModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
NetworkModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
BacklightModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }
BatteryModule { parentWindow: barWindow; globalMenu: barWindow.globalMenu }

StartModule {
id: startModuleInstance
parentWindow: barWindow
globalMenu: barWindow.globalMenu
}
}
}

// --- CENTRO ---
ClockModule {
parentWindow: barWindow
globalMenu: barWindow.globalMenu
anchors.centerIn: parent
z: 2
}
}
}
