import QtQuick
import Quickshell.Io
import Quickshell.Networking

Item {
    id: networkModule

    implicitWidth: networkText.implicitWidth
    implicitHeight: 30

    readonly property string textColor: "#ebdbb2"
    readonly property string offColor: "#fb4934"
    readonly property string downColor: "#a89984"
    readonly property string connectedColor: "#458588"
    readonly property bool isWifiOn: Networking.wifiEnabled

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

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                wifiMenu.running = true;
            } else if (mouse.button === Qt.RightButton) {
                Networking.wifiEnabled = !Networking.wifiEnabled;
            }
        }
    }

    Text {
        id: networkText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        color: {
            if (!networkModule.isWifiOn) {
                return networkModule.offColor;
            }
            var dev = networkModule.getActiveDevice();
            if (!dev) {
                return networkModule.downColor;
            }
            return networkModule.connectedColor;
        }

        text: {
            var prefix = `<span style="color: ${networkModule.textColor};">nw:</span>`;
            if (!networkModule.isWifiOn) {
                return `${prefix} off`;
            }
            var dev = networkModule.getActiveDevice();
            if (!dev) {
                return `${prefix} down`;
            }

            if (dev.name.indexOf("wlan") !== -1 || dev.name.indexOf("wlp") !== -1) {
                var essid = networkModule.getWifiName(dev);
                return `${prefix} ${essid}`;
            }
            return `${prefix} ${dev.name}`;
        }
    }
}
