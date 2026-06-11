import QtQuick
import Quickshell
import "../components/themeengine"

Item {
    id: clockModule

    required property var globalMenu
    required property var parentWindow

    readonly property color labelColor: ColorRegistry.clockLabelColor
    readonly property color dayColor: ColorRegistry.clockDayColor
    readonly property color monthColor: ColorRegistry.clockMonthColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    readonly property var ptBr: Qt.locale("pt_BR")

    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockModule.parentWindow ? clockModule.parentWindow.barHeight : 30

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    Row {
        id: clockRow
        anchors.verticalCenter: parent.verticalCenter
        readonly property var formattedParts: {
            const d = systemClock.date;
            return {
                weekday: clockModule.ptBr.toString(d, "ddd"),
                day: clockModule.ptBr.toString(d, "d"),
                month: clockModule.ptBr.toString(d, "MMMM"),
                time: clockModule.ptBr.toString(d, "HH:mm")
            };
        }
        Text {
            id: clockBase
            font.family: clockModule.labelFontFamily
            font.pixelSize: clockModule.labelFontSize
            color: clockModule.labelColor
            text: `${clockRow.formattedParts.weekday} `
        }
        Text {
            font: clockBase.font
            color: clockModule.dayColor
            text: clockRow.formattedParts.day
        }
        Text {
            font: clockBase.font
            color: clockBase.color
            text: " de "
        }
        Text {
            font: clockBase.font
            color: clockModule.monthColor
            text: clockRow.formattedParts.month
        }
        Text {
            font: clockBase.font
            color: clockBase.color
            text: ` - ${clockRow.formattedParts.time}`
        }
    }
}
