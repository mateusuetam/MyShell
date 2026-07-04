import QtQuick
import Quickshell.Services.UPower
import "../core"

Item {
id: batteryModule

required property var globalMenu
required property var parentWindow

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
color: ThemeRegistry.batteryErrorColor,
text: "--%"
};
}
const pct = batteryModule.realPercentage;
const rate = Math.round(Math.abs(dev.changeRate));
if (!UPower.onBattery) {
return {
color: ThemeRegistry.batteryChargingColor,
text: batteryModule.isFull ? "AC/ON" : `${pct}% - ${rate}W`
};
}
let uiColor = ThemeRegistry.batteryNormalColor;
if (pct <= 20) {
uiColor = ThemeRegistry.batteryCriticalColor;
} else if (pct <= 30) {
uiColor = ThemeRegistry.batteryLowColor;
}
return {
color: uiColor,
text: `${pct}% - ${rate}W`
};
}
Text {
id: batteryPrefix
font.family: ThemeRegistry.appliedFontFamily
font.pixelSize: ThemeRegistry.appliedFontSize
color: ThemeRegistry.batteryLabelColor
text: "BA: "
}
Text {
font: batteryPrefix.font
color: batteryRow.batteryState.color
text: batteryRow.batteryState.text
}
}
}
