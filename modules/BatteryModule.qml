import QtQuick
import Quickshell.Services.UPower
import "../components/themeengine"

Item {
id: batteryModule

required property var globalMenu
required property var parentWindow

readonly property color labelColor: ThemeRegistry.batteryLabelColor
readonly property color errorColor: ThemeRegistry.batteryErrorColor
readonly property color chargingColor: ThemeRegistry.batteryChargingColor
readonly property color criticalColor: ThemeRegistry.batteryCriticalColor
readonly property color lowColor: ThemeRegistry.batteryLowColor
readonly property color normalColor: ThemeRegistry.batteryNormalColor
readonly property string labelFontFamily: ThemeRegistry.appliedFontFamily
readonly property int labelFontSize: ThemeRegistry.appliedFontSize

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
