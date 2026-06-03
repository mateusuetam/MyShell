import QtQuick
import Quickshell.Services.UPower
import "../components/theme"

Text {
    id: batteryModule

    readonly property var dev: UPower.displayDevice
    readonly property int realPercentage: (dev && dev.ready) ? Math.round(dev.percentage * 100) : 0
    readonly property bool isFull: dev ? (dev.state === UPowerDeviceState.FullyCharged || (realPercentage >= 95 && dev.changeRate === 0)) : false

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    anchors.verticalCenter: parent.verticalCenter

    color: {
        if (!dev || !dev.ready)
            return Theme.brightColor;
        if (!UPower.onBattery)
            return Theme.positiveColor;
        if (realPercentage <= 20)
            return Theme.warmColor;
        if (realPercentage <= 30)
            return Theme.flashyColor;
        return Theme.brightColor;
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
