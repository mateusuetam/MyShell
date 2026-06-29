import QtQuick
import Quickshell.Services.UPower
import "../components/themeengine"

Item {
id: batteryModule

required property var globalMenu
required property var parentWindow

readonly property color labelColor: ColorRegistry.batteryLabelColor
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

implicitWidth: batteryRow.implicitWidth
implicitHeight: batteryModule.parentWindow ? batteryModule.parentWindow.barHeight : 30

Row {
id: batteryRow
anchors.verticalCenter: parent.verticalCenter
readonly property var batteryState: {
const dev = batteryModule.dev;
if (!dev || !dev.ready) {
return {
color: batteryModule.errorColor,
text: "--%"
};
}
const pct = batteryModule.realPercentage;
const rate = Math.round(Math.abs(dev.changeRate));
if (!UPower.onBattery) {
return {
color: batteryModule.chargingColor,
text: batteryModule.isFull ? "AC/ON" : `${pct}% - ${rate}W`
};
}
let uiColor = batteryModule.normalColor;
if (pct <= 20) {
uiColor = batteryModule.criticalColor;
} else if (pct <= 30) {
uiColor = batteryModule.lowColor;
}
return {
color: uiColor,
text: `${pct}% - ${rate}W`
};
}
Text {
id: batteryPrefix
font.family: batteryModule.labelFontFamily
font.pixelSize: batteryModule.labelFontSize
color: batteryModule.labelColor
text: "BA: "
}
Text {
font: batteryPrefix.font
color: batteryRow.batteryState.color
text: batteryRow.batteryState.text
}
}
}
