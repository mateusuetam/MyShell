import QtQuick
import QtQuick.Layouts

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 40
    spacing: 0

    Text {
        id: clock
        property var date: new Date()
        Layout.alignment: Qt.AlignHCenter

        renderType: Text.NativeRendering
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 110
        font.bold: true
        color: "#8ec07c"

        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.date = new Date()
        }

        text: {
            const hours = this.date.getHours().toString().padStart(2, '0');
            const minutes = this.date.getMinutes().toString().padStart(2, '0');
            return `${hours}:${minutes}`;
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: "SOBREPOSIÇÃO DE HORA DO SISTEMA"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.letterSpacing: 4
        color: "#504945"
    }
}
