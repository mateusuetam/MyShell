import QtQuick
import Quickshell.Services.UPower

Text {
    id: batteryModule

    readonly property color colorNormal: "#fabd2f"
    readonly property color chargingColor: "#b8bb26"
    readonly property color warningColor: "#fe8019"
    readonly property color criticalColor: "#fb4934"
    readonly property var dev: UPower.displayDevice
    readonly property int realPercentage: (dev && dev.ready) ? Math.round(dev.percentage * 100) : 0
    readonly property bool isFull: dev ? (dev.state === UPowerDeviceState.FullyCharged || (realPercentage >= 95 && dev.changeRate === 0)) : false

    font.family: "JetBrainsMono Nerd Font Propo"
    font.pixelSize: 14
    anchors.verticalCenter: parent.verticalCenter

    color: {
        if (!dev || !dev.ready)
            return colorNormal;
        if (!UPower.onBattery)
            return chargingColor;
        if (realPercentage <= 20)
            return criticalColor;
        if (realPercentage <= 30)
            return warningColor;
        return normalColor;
    }

    text: {
        if (!dev || !dev.ready)
            return "bat: --%";
        if (!UPower.onBattery) {
            return isFull ? `bat: ${realPercentage}% [AC]` : `bat: ${realPercentage}% +${Math.round(Math.abs(dev.changeRate))}W`;
        }
        return `bat: ${realPercentage}% - ${Math.round(Math.abs(dev.changeRate))}W`;
    }
}
