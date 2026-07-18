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

// Mpris
readonly property color mprisPlayingColor: ThemeEngine.palette.green
readonly property color mprisPausedColor: ThemeEngine.palette.blue

// Idle
readonly property color idleActivatedColor: ThemeEngine.palette.greenSoft
readonly property color idleDeactivatedColor: ThemeEngine.palette.gray

// Microphone
readonly property color microphoneMutedColor: ThemeEngine.palette.orange
readonly property color microphoneActiveColor: ThemeEngine.palette.greenBright
readonly property color microphoneLabelColor: ThemeEngine.palette.foreground

// Volume
readonly property color volumeMutedColor: ThemeEngine.palette.orange
readonly property color volumeActiveColor: ThemeEngine.palette.greenBright
readonly property color volumeLabelColor: ThemeEngine.palette.foreground

// Clipboard
readonly property color clipboardLabelColor: ThemeEngine.palette.purple

// Bluetooth
readonly property color bluetoothDisabledColor: ThemeEngine.palette.redBright
readonly property color bluetoothDisconnectedColor: ThemeEngine.palette.gray
readonly property color bluetoothConnectedColor: ThemeEngine.palette.blue
readonly property color bluetoothLabelColor: ThemeEngine.palette.foreground

// Network
readonly property color networkDisabledColor: ThemeEngine.palette.redBright
readonly property color networkDisconnectedColor: ThemeEngine.palette.gray
readonly property color networkConnectedColor: ThemeEngine.palette.blue
readonly property color networkLabelColor: ThemeEngine.palette.foreground

// Backlight
readonly property color backlightBrightnessColor: ThemeEngine.palette.yellowBright
readonly property color backlightLabelColor: ThemeEngine.palette.foreground

// Battery
readonly property color batteryErrorColor: ThemeEngine.palette.red
readonly property color batteryChargingColor: ThemeEngine.palette.greenBright
readonly property color batteryCriticalColor: ThemeEngine.palette.redBright
readonly property color batteryLowColor: ThemeEngine.palette.orange
readonly property color batteryNormalColor: ThemeEngine.palette.yellowBright
readonly property color batteryLabelColor: ThemeEngine.palette.foreground

// Clock
readonly property color clockLabelColor: ThemeEngine.palette.foreground
readonly property color clockDayColor: ThemeEngine.palette.greenSoft
readonly property color clockMonthColor: ThemeEngine.palette.purple

// Start
readonly property color sLabelColor: ThemeEngine.palette.orange
readonly property color t1LabelColor: ThemeEngine.palette.greenBright
readonly property color aLabelColor: ThemeEngine.palette.cyan
readonly property color rLabelColor: ThemeEngine.palette.yellowBright
readonly property color t2LabelColor: ThemeEngine.palette.purpleBright
readonly property color startSeparatorColor: ThemeEngine.palette.foreground

// Shell
readonly property color backgroundColor: ThemeEngine.palette.background
readonly property color borderColor: ThemeEngine.palette.surface
readonly property color borderLowColor: ThemeEngine.palette.greenBright
readonly property color borderNormalColor: ThemeEngine.palette.cyan
readonly property color borderCriticalColor: ThemeEngine.palette.redBright
readonly property color notificationContentColor: ThemeEngine.palette.foreground
property color dynamicBorderColor: borderColor

// Menu
readonly property color menuBackgroundColor: ThemeEngine.palette.background
readonly property color menuBorderColor: ThemeEngine.palette.surface
readonly property color menuTextHoverColor: ThemeEngine.palette.surfaceVariant
readonly property color menuTextColor: ThemeEngine.palette.foreground
readonly property color menuHoverColor: ThemeEngine.palette.orange
readonly property color menuErrorColor: ThemeEngine.palette.redBright

// Lockscreen
readonly property color lockClockColor: ThemeEngine.palette.green
readonly property color lockLabelClockColor: ThemeEngine.palette.surfaceVariant
readonly property color lockHeaderAccentColor: ThemeEngine.palette.surfaceVariant
readonly property color lockPromptLabelColor: ThemeEngine.palette.yellow
readonly property color lockPromptInputActiveColor: ThemeEngine.palette.greenSoft
readonly property color lockPromptInputInactiveColor: ThemeEngine.palette.green
readonly property color lockPromptErrorColor: ThemeEngine.palette.red
readonly property color lockScreenBackgroundColor: ThemeEngine.palette.background
}
