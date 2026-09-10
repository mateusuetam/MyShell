pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: gruvboxLightPalette

readonly property color dark1: "#3c3836"
readonly property color gray0: "#928374"
readonly property color light0: "#fbf1c7"
readonly property color light0_soft: "#f2e5bc"
readonly property color light4: "#a89984"
readonly property color faded_red: "#9d0006"
readonly property color faded_green: "#79740e"
readonly property color faded_yellow: "#b57614"
readonly property color faded_blue: "#076678"
readonly property color faded_purple: "#8f3f71"
readonly property color faded_aqua: "#427b58"
readonly property color faded_orange: "#af3a03"
readonly property color neutral_orange: "#d65d0e"

// LoadingWindow
readonly property color loadingBackground: light0
readonly property color loadingText: dark1

// ContextMenu
readonly property color menuTextHoverColor: light0_soft
readonly property color menuTextColor: dark1
readonly property color menuHoverColor: neutral_orange
readonly property color menuErrorColor: faded_red

// Shell
readonly property int shellRadius: 0
readonly property color backgroundColor: light0
readonly property color borderColor: light4
readonly property color borderLowColor: faded_green
readonly property color borderNormalColor: faded_blue
readonly property color borderCriticalColor: faded_red
readonly property color notificationContentColor: dark1

// Mpris
readonly property color mprisPlayingColor: faded_aqua
readonly property color mprisPausedColor: faded_blue

// Idle
readonly property color idleActivatedColor: faded_yellow
readonly property color idleDeactivatedColor: gray0

// Clipboard
readonly property color clipboardLabelColor: faded_purple

// Microphone
readonly property color microphoneMutedColor: faded_orange
readonly property color microphoneActiveColor: faded_green

// Volume
readonly property color volumeMutedColor: faded_orange
readonly property color volumeActiveColor: faded_green

// Bluetooth
readonly property color bluetoothDisabledColor: faded_red
readonly property color bluetoothDisconnectedColor: gray0
readonly property color bluetoothConnectedColor: faded_blue

// Network
readonly property color networkDisabledColor: faded_red
readonly property color networkDisconnectedColor: gray0
readonly property color networkConnectedColor: faded_blue

// Backlight
readonly property color backlightBrightnessColor: faded_yellow

// Battery
readonly property color batteryErrorColor: faded_red
readonly property color batteryChargingColor: faded_green
readonly property color batteryCriticalColor: faded_red
readonly property color batteryLowColor: faded_orange
readonly property color batteryNormalColor: faded_aqua

// Clock
readonly property color clockLabelColor: dark1
readonly property color clockDayColor: faded_aqua
readonly property color clockMonthColor: faded_purple

// Start
readonly property color startLabelColor: dark1

// Lockscreen
readonly property color lockTextColor: dark1
readonly property color lockInputBorderColor: neutral_orange
readonly property color lockErrorColor: faded_red
readonly property color lockScreenBackgroundColor: light0
}
