import QtQuick
import QtQuick.Layouts
import "../theme"

ColumnLayout {
    Layout.fillWidth: true
    spacing: 5

    Text {
        text: "MU-TH-UR 6000 // INTERFACE DE SESSÃO SEGURA"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        color: Theme.hoverColor
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.hoverColor
    }
}
