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
readonly property color loadingBarBackground: _nc
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
readonly property color borderColor: highlight_med
readonly property color borderLowColor: leaf
readonly property color borderNormalColor: iris
readonly property color borderCriticalColor: love
readonly property color notificationContentColor: text

// Mpris
readonly property color mprisPlayingColor: foam
readonly property color mprisPausedColor: muted

// Idle
readonly property color idleActivatedColor: love
readonly property color idleDeactivatedColor: muted

// Clipboard
readonly property color clipboardLabelColor: iris

// Microphone
readonly property color microphoneMutedColor: muted
readonly property color microphoneActiveColor: rose

// Volume
readonly property color volumeMutedColor: muted
readonly property color volumeActiveColor: rose

// Bluetooth
readonly property color bluetoothDisabledColor: muted
readonly property color bluetoothDisconnectedColor: love
readonly property color bluetoothConnectedColor: foam

// Network
readonly property color networkDisabledColor: muted
readonly property color networkDisconnectedColor: love
readonly property color networkConnectedColor: foam

// Backlight
readonly property color backlightBrightnessColor: gold

// Battery
readonly property color batteryErrorColor: love
readonly property color batteryChargingColor: leaf
readonly property color batteryCriticalColor: love
readonly property color batteryLowColor: rose
readonly property color batteryNormalColor: gold

// Clock
readonly property color clockLabelColor: text
readonly property color clockDayColor: iris
readonly property color clockMonthColor: love

// Start
readonly property color startLabelColor: text

// Lockscreen
readonly property color lockLabelColor: highlight_high
readonly property color lockPromptLabelColor: rose
readonly property color lockInputLabelColor: highlight_high
readonly property color lockPromptErrorColor: love
readonly property color lockScreenBackgroundColor: base
}
