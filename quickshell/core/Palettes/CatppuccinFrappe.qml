pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: catppuccinFrappePalette

readonly property color flamingo: "#eebebe"
readonly property color pink: "#f4b8e4"
readonly property color mauve: "#ca9ee6"
readonly property color red: "#e78284"
readonly property color maroon: "#ea999c"
readonly property color peach: "#ef9f76"
readonly property color yellow: "#e5c890"
readonly property color green:"#a6d189"
readonly property color sky: "#99d1db"
readonly property color sapphire: "#85c1dc"
readonly property color blue: "#8caaee"
readonly property color lavender: "#babbf1"
readonly property color textFg: "#c6d0f5"
readonly property color surface1: "#51576d"
readonly property color base: "#303446"
readonly property color crust: "#232634"

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
