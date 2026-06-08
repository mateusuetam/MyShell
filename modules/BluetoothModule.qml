import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth
import "../components/themeengine"

Item {
    id: bluetoothModule

    required property var globalMenu
    required property var parentWindow

    readonly property color disabledColor: ColorRegistry.bluetoothDisabledColor
    readonly property color disconnectedColor: ColorRegistry.bluetoothDisconnectedColor
    readonly property color connectedColor: ColorRegistry.bluetoothConnectedColor
    readonly property color labelColor: ColorRegistry.bluetoothLabelColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devicesModel: Bluetooth.devices
    readonly property bool isBluetoothOn: adapter ? adapter.enabled : false

    implicitWidth: bluetoothRow.implicitWidth
    implicitHeight: bluetoothModule.parentWindow ? bluetoothModule.parentWindow.barHeight : 30

    function getConnectedDevice() {
        const list = devicesModel?.values ?? [];
        for (let i = 0; i < list.length; ++i) {
            const dev = list[i];
            if (dev?.connected)
                return dev;
        }
        return null;
    }

    Process {
        id: btMenu
        command: ["sh", "-c", "$HOME/Documentos/repos/configs/scripts/blue.sh"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            let menu = bluetoothModule.globalMenu;
            if (menu) {
                menu.close();
            }
            mouse.accepted = true;
            if (mouse.button === Qt.LeftButton) {
                btMenu.running = true;
            } else if (mouse.button === Qt.RightButton) {
                if (bluetoothModule.adapter) {
                    bluetoothModule.adapter.enabled = !bluetoothModule.adapter.enabled;
                }
            }
        }
    }

    Row {
        id: bluetoothRow
        anchors.verticalCenter: parent.verticalCenter
        readonly property var btState: {
            if (!bluetoothModule.isBluetoothOn) {
                return {
                    color: bluetoothModule.disabledColor,
                    text: "off"
                };
            }
            const dev = bluetoothModule.getConnectedDevice();
            if (!dev) {
                return {
                    color: bluetoothModule.disconnectedColor,
                    text: "unpaired"
                };
            }
            if (dev.batteryAvailable) {
                const batPercent = Math.round(dev.battery * 100);
                return {
                    color: bluetoothModule.connectedColor,
                    text: `${dev.name} (${batPercent}%)`
                };
            }
            return {
                color: bluetoothModule.connectedColor,
                text: dev.name
            };
        }
        Text {
            id: btPrefix
            font.family: bluetoothModule.labelFontFamily
            font.pixelSize: bluetoothModule.labelFontSize
            color: bluetoothModule.labelColor
            text: "bt: "
        }
        Text {
            font: btPrefix.font
            color: bluetoothRow.btState.color
            text: bluetoothRow.btState.text
        }
    }
}
