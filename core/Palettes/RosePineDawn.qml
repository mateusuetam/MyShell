pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: rosePineDawnPalette

readonly property color _nc: "#f8f0e7"
readonly property color base: "#faf4ed"
readonly property color surface: "#fffaf3"
readonly property color overlay: "#f2e9e1"
readonly property color muted: "#9893a5"
readonly property color subtle: "#797593"
readonly property color text: "#464261"
readonly property color love: "#b4637a"
readonly property color gold: "#ea9d34"
readonly property color rose: "#d7827e"
readonly property color pine: "#286983"
readonly property color foam: "#56949f"
readonly property color iris: "#907aa9"
readonly property color leaf: "#6d8f89"
readonly property color highlight_low: "#f4ede8"
readonly property color highlight_med: "#dfdad9"
readonly property color highlight_high: "#cecacd"

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
