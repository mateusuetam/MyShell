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
readonly property color loadingBarBackground: subtle
readonly property color loadingProgress: rose
readonly property color loadingCanvas: leaf
readonly property color loadingText: text

// ContextMenu
readonly property color menuTextHoverColor: surface
readonly property color menuTextColor: text
readonly property color menuHoverColor: love
readonly property color menuErrorColor: love

// Shell
readonly property int shellRadius: 6
readonly property color backgroundColor: base
readonly property color borderColor: subtle
readonly property color borderLowColor: pine
readonly property color borderNormalColor: gold
readonly property color borderCriticalColor: love
readonly property color notificationContentColor: text

// Mpris
readonly property color mprisPlayingColor: text
readonly property color mprisPausedColor: muted

// Idle
readonly property color idleActivatedColor: text
readonly property color idleDeactivatedColor: muted

// Clipboard
readonly property color clipboardLabelColor: text

// Microphone
readonly property color microphoneMutedColor: muted
readonly property color microphoneActiveColor: text

// Volume
readonly property color volumeMutedColor: muted
readonly property color volumeActiveColor: text

// Bluetooth
readonly property color bluetoothDisabledColor: muted
readonly property color bluetoothDisconnectedColor: love
readonly property color bluetoothConnectedColor: text

// Network
readonly property color networkDisabledColor: muted
readonly property color networkDisconnectedColor: love
readonly property color networkConnectedColor: text

// Backlight
readonly property color backlightBrightnessColor: text

// Battery
readonly property color batteryErrorColor: love
readonly property color batteryChargingColor: gold
readonly property color batteryCriticalColor: love
readonly property color batteryLowColor: love
readonly property color batteryNormalColor: text

// Clock
readonly property color clockLabelColor: text
readonly property color clockDayColor: pine
readonly property color clockMonthColor: love

// Start
readonly property color startLabelColor: text

// Lockscreen
readonly property color lockLabelColor: muted
readonly property color lockPromptLabelColor: rose
readonly property color lockInputLabelColor: muted
readonly property color lockPromptErrorColor: love
readonly property color lockScreenBackgroundColor: base
}
