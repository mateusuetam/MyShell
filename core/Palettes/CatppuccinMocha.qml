pragma Singleton
import QtQuick

QtObject {
id: catppuccinMochaPalette

readonly property color rosewater: "#f5e0dc"
readonly property color flamingo: "#f2cdcd"
readonly property color pink: "#f5c2e7"
readonly property color mauve: "#cba6f7"
readonly property color red: "#f38ba8"
readonly property color maroon: "#eba0ac"
readonly property color peach: "#fab387"
readonly property color yellow: "#f9e2af"
readonly property color green: "#a6e3a1"
readonly property color teal: "#94e2d5"
readonly property color sky: "#89dceb"
readonly property color sapphire: "#74c7ec"
readonly property color blue: "#89b4fa"
readonly property color lavender: "#b4befe"

readonly property color textFg: "#cdd6f4"
readonly property color subtext1: "#bac2de"
readonly property color subtext0: "#a6adc8"

readonly property color overlay2: "#9399b2"
readonly property color overlay1: "#7f849c"
readonly property color overlay0: "#6c7086"

readonly property color surface2: "#585b70"
readonly property color surface1: "#45475a"
readonly property color surface0: "#313244"

readonly property color base: "#1e1e2e"
readonly property color mantle: "#181825"
readonly property color crust: "#11111b"

// ContextMenu
readonly property color menuBackgroundColor: base
readonly property color menuBorderColor: surface1
readonly property color menuTextHoverColor: crust
readonly property color menuTextColor: textFg
readonly property color menuHoverColor: lavender
readonly property color menuErrorColor: red

// Mainbar/Notifications
readonly property color backgroundColor: base
readonly property color borderColor: surface1
readonly property color borderLowColor: green
readonly property color borderNormalColor: sapphire
readonly property color borderCriticalColor: red
readonly property color notificationContentColor: textFg
property color dynamicBorderColor: borderColor

// Start
readonly property color startLabelColor: textFg

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

// Lockscreen
readonly property color lockLabelColor: surface2
readonly property color lockPromptLabelColor: yellow
readonly property color lockPromptInputActiveColor: textFg
readonly property color lockPromptErrorColor: red
readonly property color lockScreenBackgroundColor: base
}
