import QtQuick
import Quickshell

Text {
    id: clockModule

    readonly property string textColor: "#ebdbb2"

    font.family: "JetBrainsMono Nerd Font Propo"
    font.pixelSize: 14
    color: clockModule.textColor
    anchors.verticalCenter: parent.verticalCenter

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    text: `${Qt.formatDateTime(systemClock.date, "ddd, d 'de' MMMM")} | ${Qt.formatDateTime(systemClock.date, "hh:mm")}`
}
