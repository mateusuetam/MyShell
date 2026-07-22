pragma Singleton
import QtQuick

QtObject {
id: gruvboxDarkPalette

readonly property color dark0_hard: "#1d2021"
readonly property color dark0: "#282828"
readonly property color dark0_soft: "#32302f"
readonly property color dark1: "#3c3836"
readonly property color dark2: "#504945"
readonly property color dark3: "#665c54"
readonly property color dark4: "#7c6f64"

readonly property color gray0: "#928374"

readonly property color light0_hard: "#f9f5d7"
readonly property color light0: "#fbf1c7"
readonly property color light0_soft: "#f2e5bc"
readonly property color light1: "#ebdbb2"
readonly property color light2: "#d5c4a1"
readonly property color light3: "#bdae93"
readonly property color light4: "#a89984"

readonly property color faded_red: "#9d0006"
readonly property color faded_green: "#79740e"
readonly property color faded_yellow: "#b57614"
readonly property color faded_blue: "#076678"
readonly property color faded_purple: "#8f3f71"
readonly property color faded_aqua: "#427b58"
readonly property color faded_orange: "#af3a03"

readonly property color neutral_red: "#cc241d"
readonly property color neutral_green: "#98971a"
readonly property color neutral_yellow: "#d79921"
readonly property color neutral_blue: "#458588"
readonly property color neutral_purple: "#b16286"
readonly property color neutral_aqua: "#689d6a"
readonly property color neutral_orange: "#d65d0e"

readonly property color bright_red: "#fb4934"
readonly property color bright_green: "#b8bb26"
readonly property color bright_yellow: "#fabd2f"
readonly property color bright_blue: "#83a598"
readonly property color bright_purple: "#d3869b"
readonly property color bright_aqua: "#8ec07c"
readonly property color bright_orange: "#fe8019"

// ContextMenu
readonly property color menuBackgroundColor: dark0
readonly property color menuBorderColor: dark0_hard
readonly property color menuTextHoverColor: dark0_soft
readonly property color menuTextColor: light1
readonly property color menuHoverColor: bright_blue
readonly property color menuErrorColor: bright_red

// Mainbar/Notifications
readonly property color backgroundColor: dark0
readonly property color borderColor: dark0_hard
readonly property color borderLowColor: bright_green
readonly property color borderNormalColor: bright_blue
readonly property color borderCriticalColor: bright_red
readonly property color notificationContentColor: light1
property color dynamicBorderColor: borderColor

// Start
readonly property color sLabelColor: neutral_orange
readonly property color t1LabelColor: neutral_green
readonly property color aLabelColor: neutral_aqua
readonly property color rLabelColor: neutral_yellow
readonly property color t2LabelColor: neutral_purple

// Mpris
readonly property color mprisPlayingColor: bright_aqua
readonly property color mprisPausedColor: bright_blue

// Idle
readonly property color idleActivatedColor: bright_yellow
readonly property color idleDeactivatedColor: gray0

// Clipboard
readonly property color clipboardLabelColor: neutral_purple

// Microphone
readonly property color microphoneMutedColor: neutral_orange
readonly property color microphoneActiveColor: neutral_green

// Volume
readonly property color volumeMutedColor: neutral_orange
readonly property color volumeActiveColor: neutral_green

// Bluetooth
readonly property color bluetoothDisabledColor: neutral_red
readonly property color bluetoothDisconnectedColor: gray0
readonly property color bluetoothConnectedColor: neutral_blue

// Network
readonly property color networkDisabledColor: neutral_red
readonly property color networkDisconnectedColor: gray0
readonly property color networkConnectedColor: neutral_blue

// Backlight
readonly property color backlightBrightnessColor: neutral_yellow

// Battery
readonly property color batteryErrorColor: bright_red
readonly property color batteryChargingColor: bright_green
readonly property color batteryCriticalColor: bright_red
readonly property color batteryLowColor: bright_orange
readonly property color batteryNormalColor: neutral_aqua

// Clock
readonly property color clockLabelColor: light1
readonly property color clockDayColor: bright_aqua
readonly property color clockMonthColor: bright_purple

// Lockscreen
readonly property color lockClockColor: gray0
readonly property color lockLabelClockColor: gray0
readonly property color lockHeaderAccentColor: gray0
readonly property color lockPromptLabelColor: bright_yellow
readonly property color lockPromptInputActiveColor: faded_green
readonly property color lockPromptInputInactiveColor: dark4
readonly property color lockPromptErrorColor: bright_red
readonly property color lockScreenBackgroundColor: dark0
}
