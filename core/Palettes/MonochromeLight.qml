pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

QtObject {
id: monochromeLight

readonly property color bg: "#ffffff"
readonly property color fg: "#000000"
readonly property color fg2: "#333333"
readonly property color fg3: "#666666"
readonly property color fg4: "#cccccc"

// LoadingWindow
readonly property color loadingBackground: bg
readonly property color loadingBarBackground: fg3
readonly property color loadingProgress: fg
readonly property color loadingCanvas: fg2
readonly property color loadingText: fg

// ContextMenu
readonly property color menuTextHoverColor: bg
readonly property color menuTextColor: fg
readonly property color menuHoverColor: fg
readonly property color menuErrorColor: fg4

// Shell
readonly property int shellRadius: 20
readonly property color backgroundColor: bg
readonly property color borderColor: fg
readonly property color borderLowColor: fg2
readonly property color borderNormalColor: fg3
readonly property color borderCriticalColor: fg4
readonly property color notificationContentColor: fg

// Mpris
readonly property color mprisPlayingColor: fg
readonly property color mprisPausedColor: fg3

// Idle
readonly property color idleActivatedColor: fg
readonly property color idleDeactivatedColor: fg3

// Clipboard
readonly property color clipboardLabelColor: fg

// Microphone
readonly property color microphoneMutedColor: fg3
readonly property color microphoneActiveColor: fg

// Volume
readonly property color volumeMutedColor: fg3
readonly property color volumeActiveColor: fg

// Bluetooth
readonly property color bluetoothDisabledColor: fg3
readonly property color bluetoothDisconnectedColor: fg2
readonly property color bluetoothConnectedColor: fg

// Network
readonly property color networkDisabledColor: fg3
readonly property color networkDisconnectedColor: fg2
readonly property color networkConnectedColor: fg

// Backlight
readonly property color backlightBrightnessColor: fg

// Battery
readonly property color batteryErrorColor: fg4
readonly property color batteryChargingColor: fg2
readonly property color batteryCriticalColor: fg4
readonly property color batteryLowColor: fg3
readonly property color batteryNormalColor: fg

// Clock
readonly property color clockLabelColor: fg
readonly property color clockDayColor: fg2
readonly property color clockMonthColor: fg2

// Start
readonly property color startLabelColor: fg

// Lockscreen
readonly property color lockLabelColor: fg2
readonly property color lockPromptLabelColor: fg2
readonly property color lockInputLabelColor: fg
readonly property color lockPromptErrorColor: fg3
readonly property color lockScreenBackgroundColor: bg
}
