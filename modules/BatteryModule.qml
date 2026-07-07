import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower
import "../core"

Item {
id: batteryModule

required property var globalMenu
required property var parentWindow

readonly property var dev: UPower.displayDevice
readonly property int realPercentage: (dev && dev.ready) ? Math.round(dev.percentage * 100) : 0
readonly property bool isFull: dev ? (dev.state === UPowerDeviceState.FullyCharged || (realPercentage >= 95 && dev.changeRate === 0)) : false

property int lastNotifiedLevel: 100

property bool isDischarging: UPower.onBattery
onIsDischargingChanged: {
if (!isDischarging) {
lastNotifiedLevel = 100;
}
}

Process {
id: notifyAction
}

function sendBatteryNotification(urgency, message) {
notifyAction.command = ["notify-send", "-u", urgency, "Bateria", message];
notifyAction.startDetached();
}

onRealPercentageChanged: {
if (!isDischarging) return;

if (realPercentage <= 20 && lastNotifiedLevel > 20) {
sendBatteryNotification("critical", "Nível Crítico! Conecte o carregador. (" + realPercentage + "%)");
lastNotifiedLevel = 20;

} else if (realPercentage <= 30 && lastNotifiedLevel > 30) {
sendBatteryNotification("normal", "A bateria está començando a ficar baixa. (" + realPercentage + "%)");
lastNotifiedLevel = 30;

} else if (realPercentage <= 49 && lastNotifiedLevel > 49) {
sendBatteryNotification("low", "A bateria está abaixo da metade. (" + realPercentage + "%)");
lastNotifiedLevel = 49;
}
}

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
