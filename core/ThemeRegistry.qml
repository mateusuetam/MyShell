pragma Singleton
import QtQuick

QtObject {
id: theme

/* ===================
REGISTRO DE TIPOGRAFIA
====================== */
readonly property string appliedFontFamily: "Monaspace Krypton NF"
readonly property int appliedFontSize: 14
readonly property int appliedMenuFontSize: 12
readonly property int appliedHeaderFontSize: 16

/* ==============
REGISTRO DE CORES
================= */

// ContextMenu
readonly property color menuBackgroundColor: ThemeEngine.palette.menuBackgroundColor
readonly property color menuBorderColor: ThemeEngine.palette.menuBorderColor
readonly property color menuTextHoverColor: ThemeEngine.palette.menuTextHoverColor
readonly property color menuTextColor: ThemeEngine.palette.menuTextColor
readonly property color menuHoverColor: ThemeEngine.palette.menuHoverColor
readonly property color menuErrorColor: ThemeEngine.palette.menuErrorColor

// Mainbar/Notifications
readonly property color backgroundColor: ThemeEngine.palette.backgroundColor
readonly property color borderColor: ThemeEngine.palette.borderColor
readonly property color borderLowColor: ThemeEngine.palette.borderLowColor
readonly property color borderNormalColor: ThemeEngine.palette.borderNormalColor
readonly property color borderCriticalColor: ThemeEngine.palette.borderCriticalColor
readonly property color notificationContentColor: ThemeEngine.palette.notificationContentColor
property color dynamicBorderColor: borderColor

// Start
readonly property color startLabelColor: ThemeEngine.palette.startLabelColor

// Mpris
readonly property color mprisPlayingColor: ThemeEngine.palette.mprisPlayingColor
readonly property color mprisPausedColor: ThemeEngine.palette.mprisPausedColor

// Idle
readonly property color idleActivatedColor: ThemeEngine.palette.idleActivatedColor
readonly property color idleDeactivatedColor: ThemeEngine.palette.idleDeactivatedColor

// Clipboard
readonly property color clipboardLabelColor: ThemeEngine.palette.clipboardLabelColor

// Microphone
readonly property color microphoneMutedColor: ThemeEngine.palette.microphoneMutedColor
readonly property color microphoneActiveColor: ThemeEngine.palette.microphoneActiveColor

// Volume
readonly property color volumeMutedColor: ThemeEngine.palette.volumeMutedColor
readonly property color volumeActiveColor: ThemeEngine.palette.volumeActiveColor

// Bluetooth
readonly property color bluetoothDisabledColor: ThemeEngine.palette.bluetoothDisabledColor
readonly property color bluetoothDisconnectedColor: ThemeEngine.palette.bluetoothDisconnectedColor
readonly property color bluetoothConnectedColor: ThemeEngine.palette.bluetoothConnectedColor

// Network
readonly property color networkDisabledColor: ThemeEngine.palette.networkDisabledColor
readonly property color networkDisconnectedColor: ThemeEngine.palette.networkDisconnectedColor
readonly property color networkConnectedColor: ThemeEngine.palette.networkConnectedColor

// Backlight
readonly property color backlightBrightnessColor: ThemeEngine.palette.backlightBrightnessColor

// Battery
readonly property color batteryErrorColor: ThemeEngine.palette.batteryErrorColor
readonly property color batteryChargingColor: ThemeEngine.palette.batteryChargingColor
readonly property color batteryCriticalColor: ThemeEngine.palette.batteryCriticalColor
readonly property color batteryLowColor: ThemeEngine.palette.batteryLowColor
readonly property color batteryNormalColor: ThemeEngine.palette.batteryNormalColor

// Clock
readonly property color clockLabelColor: ThemeEngine.palette.clockLabelColor
readonly property color clockDayColor: ThemeEngine.palette.clockDayColor
readonly property color clockMonthColor: ThemeEngine.palette.clockMonthColor

// Lockscreen
readonly property color lockLabelColor: ThemeEngine.palette.lockLabelColor
readonly property color lockPromptLabelColor: ThemeEngine.palette.lockPromptLabelColor
readonly property color lockPromptInputActiveColor: ThemeEngine.palette.lockPromptInputActiveColor
readonly property color lockPromptErrorColor: ThemeEngine.palette.lockPromptErrorColor
readonly property color lockScreenBackgroundColor: ThemeEngine.palette.lockScreenBackgroundColor
}
