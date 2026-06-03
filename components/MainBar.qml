import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../modules"
import "../components/theme"

PanelWindow {
    id: barWindow

    property color borderColor: Theme.borderColor

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 30
    exclusiveZone: 30
    aboveWindows: true
    focusable: false

    Component.onCompleted: {
        if (this.WlrLayershell !== null) {
            this.WlrLayershell.layer = WlrLayer.Top;
        }
    }

    // --- RENDERIZAÇÃO DA BARRA ---
    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: barWindow.borderColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6

            // <<< LADO ESQUERDO <<<
            Row {
                id: leftModules
                spacing: 12
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                MprisModule {}
            }

            // >>> LADO DIREITO >>>
            Row {
                id: rightModules
                spacing: 12
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                TrayModule {
                    parentWindow: barWindow
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
