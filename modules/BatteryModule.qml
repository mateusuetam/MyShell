import QtQuick
import Quickshell.Services.UPower
import "../components/themeengine"

Text {
    id: batteryModule

    readonly property color errorColor: ColorRegistry.batteryErrorColor
    readonly property color chargingColor: ColorRegistry.batteryChargingColor
    readonly property color criticalColor: ColorRegistry.batteryCriticalColor
    readonly property color lowColor: ColorRegistry.batteryLowColor
    readonly property color normalColor: ColorRegistry.batteryNormalColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    readonly property var dev: UPower.displayDevice
    readonly property int realPercentage: (dev && dev.ready) ? Math.round(dev.percentage * 100) : 0
    readonly property bool isFull: dev ? (dev.state === UPowerDeviceState.FullyCharged || (realPercentage >= 95 && dev.changeRate === 0)) : false

    font.family: batteryModule.labelFontFamily
    font.pixelSize: batteryModule.labelFontSize
    anchors.verticalCenter: parent.verticalCenter

    color: {
        if (!dev || !dev.ready)
            return batteryModule.errorColor;
        if (!UPower.onBattery)
            return batteryModule.chargingColor;
        if (realPercentage <= 20)
            return batteryModule.criticalColor;
        if (realPercentage <= 30)
            return batteryModule.lowColor;
        return batteryModule.normalColor;
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
