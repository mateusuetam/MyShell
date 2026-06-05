import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../modules"
import "themeengine"

PanelWindow {
    id: barWindow

    property var globalMenu: null
    readonly property color barBackgroundColor: ColorRegistry.mainbarBackgroundColor
    property color barBorderColor: ColorRegistry.mainbarBorderColor
    readonly property int barHeight: 30
    readonly property int layoutSpacing: 12
    readonly property int sideMargins: 6

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mainbar"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: barWindow.barHeight
    exclusiveZone: barWindow.barHeight
    focusable: false

    // --- RENDERIZAÇÃO DA BARRA ---
    Rectangle {
        anchors.fill: parent
        color: barWindow.barBackgroundColor
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

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: barWindow.sideMargins
            anchors.rightMargin: barWindow.sideMargins

            // <<< LADO ESQUERDO <<<
            Row {
                id: leftModules

                spacing: barWindow.layoutSpacing
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                MprisModule {}
            }

            // >>> LADO DIREITO >>>
            Row {
                id: rightModules

                spacing: barWindow.layoutSpacing
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                TrayModule {
                    parentWindow: barWindow
                    globalMenu: barWindow.globalMenu
                }

                IdleModule {
                    parentWindow: barWindow
                }

                MicrophoneModule {}
                VolumeModule {}
                ClipboardModule {}
                BluetoothModule {}
                NetworkModule {}
                BacklightModule {}
                BatteryModule {}
                ClockModule {}
                PowerModule {}
            }
        }
    }
}
