import QtQuick
import Quickshell
import "../components/themeengine"

Text {
    id: clockModule

    readonly property color labelColor: ColorRegistry.clockLabelColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    font.family: clockModule.labelFontFamily
    font.pixelSize: clockModule.labelFontSize

    color: clockModule.labelColor
    anchors.verticalCenter: parent.verticalCenter

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    text: `${Qt.formatDateTime(systemClock.date, "ddd, d 'de' MMMM")} | ${Qt.formatDateTime(systemClock.date, "hh:mm")}`
}
