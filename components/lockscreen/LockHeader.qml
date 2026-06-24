import QtQuick
import QtQuick.Layouts
import "../themeengine"

ColumnLayout {
id: lockHeader

readonly property string headerText: "MU-TH-UR 6000 // INTERFACE DE SESSÃO SEGURA"
readonly property color accentColor: ColorRegistry.lockHeaderAccentColor
readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
readonly property int labelFontSize: 14

Layout.fillWidth: true
spacing: 5

Text {
text: lockHeader.headerText
font.family: lockHeader.labelFontFamily
font.pixelSize: lockHeader.labelFontSize
font.bold: true
color: lockHeader.accentColor
}

Rectangle {
Layout.fillWidth: true
implicitHeight: 1
color: lockHeader.accentColor
}
}
