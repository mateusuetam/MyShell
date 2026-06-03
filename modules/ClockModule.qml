import QtQuick
import Quickshell
import "../components/theme"

Text {
    id: clockModule

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    color: Theme.textColor
    anchors.verticalCenter: parent.verticalCenter

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    text: `${Qt.formatDateTime(systemClock.date, "ddd, d 'de' MMMM")} | ${Qt.formatDateTime(systemClock.date, "hh:mm")}`
}
