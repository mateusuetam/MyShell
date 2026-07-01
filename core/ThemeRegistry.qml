pragma Singleton
import QtQuick

QtObject {
id: theme

/* =========================
PRIMITIVE TOKENS: TIPOGRAFIA
============================ */

// Font Families
readonly property string fontKrypton: "Monaspace Krypton NF"

// Font Sizes
readonly property int sizeTiny: 10
readonly property int sizeSmall: 12
readonly property int sizeNormal: 14
readonly property int sizeMedium: 16
readonly property int sizeLarge: 18
readonly property int sizeHuge: 24

/* ======================
PRIMITIVE TOKENS: GRUVBOX
========================= */

// Backgrounds
readonly property color dark0_hard: "#1d2021"
readonly property color dark0: "#282828"
readonly property color dark0_soft: "#32302f"
readonly property color dark1: "#3c3836"
readonly property color dark2: "#504945"
readonly property color dark3: "#665c54"
readonly property color dark4: "#7c6f64"

// Foregrounds
readonly property color light0_hard: "#f9f5d7"
readonly property color light0: "#fbf1c7"
readonly property color light0_soft: "#f2e5bc"
readonly property color light1: "#ebdbb2"
readonly property color light2: "#d5c4a1"
readonly property color light3: "#bdae93"
readonly property color light4: "#a89984"

// Bright colors
readonly property color bright_red: "#fb4934"
readonly property color bright_green: "#b8bb26"
readonly property color bright_yellow: "#fabd2f"
readonly property color bright_blue: "#83a598"
readonly property color bright_purple: "#d3869b"
readonly property color bright_aqua: "#8ec07c"
readonly property color bright_orange: "#fe8019"

// Neutral colors
readonly property color neutral_red: "#cc241d"
readonly property color neutral_green: "#98971a"
readonly property color neutral_yellow: "#d79921"
readonly property color neutral_blue: "#458588"
readonly property color neutral_purple: "#b16286"
readonly property color neutral_aqua: "#689d6a"
readonly property color neutral_orange: "#d65d0e"

// Faded colors
readonly property color faded_red: "#9d0006"
readonly property color faded_green: "#79740e"
readonly property color faded_yellow: "#b57614"
readonly property color faded_blue: "#076678"
readonly property color faded_purple: "#8f3f71"
readonly property color faded_aqua: "#427b58"
readonly property color faded_orange: "#af3a03"

/* =============================================
SEMANTIC TOKENS: REGISTRO DE TIPOGRAFIA DA SHELL
================================================ */

readonly property string appliedFontFamily: fontKrypton
readonly property int appliedFontSize: sizeNormal
readonly property int appliedHeaderFontSize: sizeMedium
readonly property int appliedMenuFontSize: sizeSmall

/* ========================================
SEMANTIC TOKENS: REGISTRO DE CORES DA SHELL
=========================================== */

// Mpris
readonly property color mprisPlayingColor: neutral_aqua
readonly property color mprisPausedColor: neutral_blue

// Idle
readonly property color idleActivatedColor: bright_aqua
readonly property color idleDeactivatedColor: light4

// Microphone
readonly property color microphoneMutedColor: bright_orange
readonly property color microphoneActiveColor: bright_green
readonly property color microphoneLabelColor: light1

// Volume
readonly property color volumeMutedColor: bright_orange
readonly property color volumeActiveColor: bright_green
readonly property color volumeLabelColor: light1

// Clipboard
readonly property color clipboardLabelColor: neutral_purple

// Bluetooth
readonly property color bluetoothDisabledColor: bright_red
readonly property color bluetoothDisconnectedColor: light4
readonly property color bluetoothConnectedColor: neutral_blue
readonly property color bluetoothLabelColor: light1

// Network
readonly property color networkDisabledColor: bright_red
readonly property color networkDisconnectedColor: light4
readonly property color networkConnectedColor: neutral_blue
readonly property color networkLabelColor: light1

// Backlight
readonly property color backlightBrightnessColor: bright_yellow
readonly property color backlightLabelColor: light1

// Battery
readonly property color batteryErrorColor: neutral_red
readonly property color batteryChargingColor: bright_green
readonly property color batteryCriticalColor: bright_red
readonly property color batteryLowColor: bright_orange
readonly property color batteryNormalColor: bright_yellow
readonly property color batteryLabelColor: light1

// Clock
readonly property color clockLabelColor: light1
readonly property color clockDayColor: bright_aqua
readonly property color clockMonthColor: neutral_purple

// Start
readonly property color sLabelColor: bright_orange
readonly property color t1LabelColor: bright_green
readonly property color aLabelColor: bright_blue
readonly property color rLabelColor: bright_yellow
readonly property color t2LabelColor: bright_purple
readonly property color startSeparatorColor: light1

// Shell
readonly property color backgroundColor: dark0
readonly property color borderColor: dark1
readonly property color borderLowColor: bright_green
readonly property color borderCriticalColor: bright_red
readonly property color notificationContentColor: light1
property color dynamicBorderColor: borderColor

// Menu
readonly property color menuBackgroundColor: dark0
readonly property color menuBorderColor: dark1
readonly property color menuTextHoverColor: dark2
readonly property color menuTextColor: light1
readonly property color menuHoverColor: bright_orange
readonly property color menuErrorColor: bright_red

// Lockscreen
readonly property color lockClockColor: neutral_aqua
readonly property color lockLabelClockColor: dark2
readonly property color lockHeaderAccentColor: dark2
readonly property color lockPromptLabelColor: neutral_yellow
readonly property color lockPromptInputActiveColor: bright_aqua
readonly property color lockPromptInputInactiveColor: neutral_aqua
readonly property color lockPromptErrorColor: neutral_red
readonly property color lockScreenBackgroundColor: dark0
}
