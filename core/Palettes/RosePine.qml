pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: rosePinePalette

readonly property color _nc: "#16141f"
readonly property color base: "#191724"
readonly property color surface: "#1f1d2e"
readonly property color overlay: "#26233a"
readonly property color muted: "#6e6a86"
readonly property color subtle: "#908caa"
readonly property color text: "#e0def4"
readonly property color love: "#eb6f92"
readonly property color gold: "#f6c177"
readonly property color rose: "#ebbcba"
readonly property color pine: "#31748f"
readonly property color foam: "#9ccfd8"
readonly property color iris: "#c4a7e7"
readonly property color leaf: "#95b1ac"
readonly property color highlight_low: "#21202e"
readonly property color highlight_med: "#403d52"
readonly property color highlight_high: "#524f67"

// LoadingWindow
readonly property color loadingBackground: base
readonly property color loadingText: text

// ContextMenu
readonly property color menuTextHoverColor: surface
readonly property color menuTextColor: text
readonly property color menuHoverColor: love
readonly property color menuErrorColor: rose

// Shell
readonly property int shellRadius: 6
readonly property color backgroundColor: base
readonly property color borderColor: subtle
readonly property color borderLowColor: pine
readonly property color borderNormalColor: iris
readonly property color borderCriticalColor: love
readonly property color notificationContentColor: text

// Mpris
readonly property color mprisPlayingColor: love
readonly property color mprisPausedColor: iris

// Idle
readonly property color idleActivatedColor: iris
readonly property color idleDeactivatedColor: rose

// Clipboard
readonly property color clipboardLabelColor: iris

// Microphone
readonly property color microphoneMutedColor: rose
readonly property color microphoneActiveColor: foam

// Volume
readonly property color volumeMutedColor: rose
readonly property color volumeActiveColor: foam

// Bluetooth
readonly property color bluetoothDisabledColor: love
readonly property color bluetoothDisconnectedColor: foam
readonly property color bluetoothConnectedColor: pine

// Network
readonly property color networkDisabledColor: love
readonly property color networkDisconnectedColor: foam
readonly property color networkConnectedColor: pine

// Backlight
readonly property color backlightBrightnessColor: gold

// Battery
readonly property color batteryErrorColor: rose
readonly property color batteryChargingColor: gold
readonly property color batteryCriticalColor: love
readonly property color batteryLowColor: rose
readonly property color batteryNormalColor: foam

// Clock
readonly property color clockLabelColor: text
readonly property color clockDayColor: iris
readonly property color clockMonthColor: pine

// Start
readonly property color startLabelColor: text

// Lockscreen
readonly property color lockTextColor: text
readonly property color lockInputBorderColor: rose
readonly property color lockErrorColor: rose
readonly property color lockScreenBackgroundColor: base
}
