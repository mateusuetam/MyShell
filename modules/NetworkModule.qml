import QtQuick
import Quickshell.Io
import Quickshell.Networking
import "../components/themeengine"

Item {
    id: networkModule

    required property var globalMenu
    required property var parentWindow

    readonly property color disabledColor: ColorRegistry.networkDisabledColor
    readonly property color disconnectedColor: ColorRegistry.networkDisconnectedColor
    readonly property color connectedColor: ColorRegistry.networkConnectedColor
    readonly property color labelColor: ColorRegistry.networkLabelColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    readonly property bool isWifiOn: Networking.wifiEnabled

    implicitWidth: networkRow.implicitWidth
    implicitHeight: networkModule.parentWindow ? networkModule.parentWindow.barHeight : 30

    function getActiveDevice() {
        var devicesList = Networking.devices.values;
        if (!devicesList)
            return null;
        for (var i = 0; i < devicesList.length; i++) {
            var dev = devicesList[i];
            if (dev && dev.connected) {
                return dev;
            }
        }
        return null;
    }

    function getWifiName(dev) {
        if (!dev || !dev.networks || !dev.networks.values)
            return "wifi";
        var networksList = dev.networks.values;
        for (var j = 0; j < networksList.length; j++) {
            var net = networksList[j];
            if (net && net.name) {
                return net.name;
            }
        }
        return "wifi";
    }

    Process {
        id: wifiMenu
        command: ["sh", "-c", "$HOME/Documentos/repos/configs/scripts/wifi.sh"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            let menu = networkModule.globalMenu;
            if (menu) {
                menu.close();
            }
            mouse.accepted = true;
            if (mouse.button === Qt.LeftButton) {
                wifiMenu.running = true;
            } else if (mouse.button === Qt.RightButton) {
                Networking.wifiEnabled = !Networking.wifiEnabled;
            }
        }
    }

    Row {
        id: networkRow
        anchors.verticalCenter: parent.verticalCenter
        readonly property var nwState: {
            if (!networkModule.isWifiOn) {
                return {
                    color: networkModule.disabledColor,
                    text: "off"
                };
            }
            const dev = networkModule.getActiveDevice();
            if (!dev) {
                return {
                    color: networkModule.disconnectedColor,
                    text: "down"
                };
            }
            const isWlan = dev.name.indexOf("wlan") !== -1 || dev.name.indexOf("wlp") !== -1;
            return {
                color: networkModule.connectedColor,
                text: isWlan ? networkModule.getWifiName(dev) : dev.name
            };
        }
        Text {
            id: networkPrefix
            font.family: networkModule.labelFontFamily
            font.pixelSize: networkModule.labelFontSize
            color: networkModule.labelColor
            text: "nw: "
        }
        Text {
            font: networkPrefix.font
            color: networkRow.nwState.color
            text: networkRow.nwState.text
        }
    }
}
