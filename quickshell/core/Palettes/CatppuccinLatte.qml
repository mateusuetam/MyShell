pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: catppuccinLattePalette

readonly property color flamingo: "#dd7878"
readonly property color pink: "#ea76cb"
readonly property color mauve: "#8839ef"
readonly property color red: "#d20f39"
readonly property color maroon: "#e64553"
readonly property color peach: "#fe640b"
readonly property color yellow: "#df8e1d"
readonly property color green: "#40a02b"
readonly property color sky: "#04a5e5"
readonly property color sapphire: "#209fb5"
readonly property color blue: "#1e66f5"
readonly property color lavender: "#7287fd"
readonly property color textFg: "#4c4f69"
readonly property color surface1: "#bcc0cc"
readonly property color base: "#eff1f5"
readonly property color crust: "#dce0e8"

// LoadingWindow
readonly property color loadingBackground: base
readonly property color loadingText: textFg

// ContextMenu
readonly property color menuTextHoverColor: crust
readonly property color menuTextColor: textFg
readonly property color menuHoverColor: lavender
readonly property color menuErrorColor: red

// Shell
readonly property int shellRadius: 12
readonly property color backgroundColor: base
readonly property color borderColor: surface1
readonly property color borderLowColor: green
readonly property color borderNormalColor: sapphire
readonly property color borderCriticalColor: red
readonly property color notificationContentColor: textFg

// Mpris
readonly property color mprisPlayingColor: yellow
readonly property color mprisPausedColor: sky

// Idle
readonly property color idleActivatedColor: green
readonly property color idleDeactivatedColor: sapphire

// Clipboard
readonly property color clipboardLabelColor: mauve

// Microphone
readonly property color microphoneMutedColor: peach
readonly property color microphoneActiveColor: pink

// Volume
readonly property color volumeMutedColor: peach
readonly property color volumeActiveColor: pink

// Bluetooth
readonly property color bluetoothDisabledColor: red
readonly property color bluetoothDisconnectedColor: flamingo
readonly property color bluetoothConnectedColor: blue

// Network
readonly property color networkDisabledColor: red
readonly property color networkDisconnectedColor: flamingo
readonly property color networkConnectedColor: blue

// Backlight
readonly property color backlightBrightnessColor: yellow

// Battery
readonly property color batteryErrorColor: red
readonly property color batteryChargingColor: green
readonly property color batteryCriticalColor: red
readonly property color batteryLowColor: maroon
readonly property color batteryNormalColor: sapphire

// Clock
readonly property color clockLabelColor: textFg
readonly property color clockDayColor: yellow
readonly property color clockMonthColor: peach

// Start
readonly property color startLabelColor: textFg

// Lockscreen
readonly property color lockTextColor: textFg
readonly property color lockInputBorderColor: lavender
readonly property color lockErrorColor: red
readonly property color lockScreenBackgroundColor: base
}
