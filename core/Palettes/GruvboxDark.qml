pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: gruvboxDarkPalette

readonly property color dark0: "#282828"
readonly property color dark0_soft: "#32302f"
readonly property color dark2: "#504945"
readonly property color gray0: "#928374"
readonly property color light1: "#ebdbb2"
readonly property color bright_red: "#fb4934"
readonly property color bright_green: "#b8bb26"
readonly property color bright_yellow: "#fabd2f"
readonly property color bright_blue: "#83a598"
readonly property color bright_purple: "#d3869b"
readonly property color bright_aqua: "#8ec07c"
readonly property color bright_orange: "#fe8019"

// LoadingWindow
readonly property color loadingBackground: dark0
readonly property color loadingText: light1

// ContextMenu
readonly property color menuTextHoverColor: dark0_soft
readonly property color menuTextColor: light1
readonly property color menuHoverColor: bright_orange
readonly property color menuErrorColor: bright_red

// Shell
readonly property int shellRadius: 0
readonly property color backgroundColor: dark0
readonly property color borderColor: dark2
readonly property color borderLowColor: bright_green
readonly property color borderNormalColor: bright_blue
readonly property color borderCriticalColor: bright_red
readonly property color notificationContentColor: light1

// Mpris
readonly property color mprisPlayingColor: bright_aqua
readonly property color mprisPausedColor: bright_blue

// Idle
readonly property color idleActivatedColor: bright_yellow
readonly property color idleDeactivatedColor: gray0

// Clipboard
readonly property color clipboardLabelColor: bright_purple

// Microphone
readonly property color microphoneMutedColor: bright_orange
readonly property color microphoneActiveColor: bright_green

// Volume
readonly property color volumeMutedColor: bright_orange
readonly property color volumeActiveColor: bright_green

// Bluetooth
readonly property color bluetoothDisabledColor: bright_red
readonly property color bluetoothDisconnectedColor: gray0
readonly property color bluetoothConnectedColor: bright_blue

// Network
readonly property color networkDisabledColor: bright_red
readonly property color networkDisconnectedColor: gray0
readonly property color networkConnectedColor: bright_blue

// Backlight
readonly property color backlightBrightnessColor: bright_yellow

// Battery
readonly property color batteryErrorColor: bright_red
readonly property color batteryChargingColor: bright_green
readonly property color batteryCriticalColor: bright_red
readonly property color batteryLowColor: bright_orange
readonly property color batteryNormalColor: bright_aqua

// Clock
readonly property color clockLabelColor: light1
readonly property color clockDayColor: bright_aqua
readonly property color clockMonthColor: bright_purple

// Start
readonly property color startLabelColor: light1

// Lockscreen
readonly property color lockTextColor: light1
readonly property color lockInputBorderColor: bright_orange
readonly property color lockErrorColor: bright_red
readonly property color lockScreenBackgroundColor: dark0
}
