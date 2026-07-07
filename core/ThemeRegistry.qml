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
readonly property color mprisPlayingColor: "#689d6a"
readonly property color mprisPausedColor: "#458588"

// Idle
readonly property color idleActivatedColor: "#8ec07c"
readonly property color idleDeactivatedColor: "#a89984"

// Microphone
readonly property color microphoneMutedColor: "#fe8019"
readonly property color microphoneActiveColor: "#b8bb26"
readonly property color microphoneLabelColor: "#ebdbb2"

// Volume
readonly property color volumeMutedColor: "#fe8019"
readonly property color volumeActiveColor: "#b8bb26"
readonly property color volumeLabelColor: "#ebdbb2"

// Clipboard
readonly property color clipboardLabelColor: "#b16286"

// Bluetooth
readonly property color bluetoothDisabledColor: "#fb4934"
readonly property color bluetoothDisconnectedColor: "#a89984"
readonly property color bluetoothConnectedColor: "#458588"
readonly property color bluetoothLabelColor: "#ebdbb2"

// Network
readonly property color networkDisabledColor: "#fb4934"
readonly property color networkDisconnectedColor: "#a89984"
readonly property color networkConnectedColor: "#458588"
readonly property color networkLabelColor: "#ebdbb2"

// Backlight
readonly property color backlightBrightnessColor: "#fabd2f"
readonly property color backlightLabelColor: "#ebdbb2"

// Battery
readonly property color batteryErrorColor: "#cc241d"
readonly property color batteryChargingColor: "#b8bb26"
readonly property color batteryCriticalColor: "#fb4934"
readonly property color batteryLowColor: "#fe8019"
readonly property color batteryNormalColor: "#fabd2f"
readonly property color batteryLabelColor: "#ebdbb2"

// Clock
readonly property color clockLabelColor: "#ebdbb2"
readonly property color clockDayColor: "#8ec07c"
readonly property color clockMonthColor: "#b16286"

// Start
readonly property color sLabelColor: "#fe8019"
readonly property color t1LabelColor: "#b8bb26"
readonly property color aLabelColor: "#83a598"
readonly property color rLabelColor: "#fabd2f"
readonly property color t2LabelColor: "#d3869b"
readonly property color startSeparatorColor: "#ebdbb2"

// Shell
readonly property color backgroundColor: "#282828"
readonly property color borderColor: "#3c3836"
readonly property color borderLowColor: "#b8bb26"
readonly property color borderNormalColor: "#83a598"
readonly property color borderCriticalColor: "#fb4934"
readonly property color notificationContentColor: "#ebdbb2"
property color dynamicBorderColor: borderColor

// Menu
readonly property color menuBackgroundColor: "#282828"
readonly property color menuBorderColor: "#3c3836"
readonly property color menuTextHoverColor: "#504945"
readonly property color menuTextColor: "#ebdbb2"
readonly property color menuHoverColor: "#fe8019"
readonly property color menuErrorColor: "#fb4934"

// Lockscreen
readonly property color lockClockColor: "#689d6a"
readonly property color lockLabelClockColor: "#504945"
readonly property color lockHeaderAccentColor: "#504945"
readonly property color lockPromptLabelColor: "#d79921"
readonly property color lockPromptInputActiveColor: "#8ec07c"
readonly property color lockPromptInputInactiveColor: "#689d6a"
readonly property color lockPromptErrorColor: "#cc241d"
readonly property color lockScreenBackgroundColor: "#282828"
}
