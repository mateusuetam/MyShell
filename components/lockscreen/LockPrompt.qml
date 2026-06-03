import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import "../theme"

ColumnLayout {
    id: promptRoot

    property bool unlockInProgress: false
    property bool showFailure: false

    Layout.alignment: Qt.AlignHCenter
    Layout.bottomMargin: 100
    spacing: 15

    signal textChanged(string val)
    signal accepted

    function clearText() {
        passwordBox.text = "";
    }

    Text {
        text: promptRoot.unlockInProgress ? "AUTENTICANDO DIRETÓRIO DE SESSÃO..." : "NOSTROMO_LOGIN_node7 > INSIRA A CHAVE DE ACESSO:"
        font.family: Theme.fontFamily
        font.pixelSize: 16
        color: Theme.brightColor
    }

    RowLayout {
        spacing: 0

        TextField {
            id: passwordBox
            implicitWidth: 400
            padding: 0

            focus: true
            enabled: !promptRoot.unlockInProgress
            echoMode: TextInput.Password

            cursorDelegate: Item {}

            font.family: Theme.fontFamily
            font.pixelSize: 22

            color: Theme.activeColor
            background: Item {}

            onTextChanged: promptRoot.textChanged(this.text)
            onAccepted: promptRoot.accepted()
        }

        Text {
            text: "▒"
            font.pixelSize: 22
            color: Theme.activeColor
            visible: !promptRoot.unlockInProgress

            Timer {
                running: true
                repeat: true
                interval: 600
                onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.0 : 1.0
            }
        }
    }

    Rectangle {
        implicitWidth: 415
        implicitHeight: 2
        color: passwordBox.activeFocus ? Theme.activeColor : Theme.borderColor
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: promptRoot.showFailure
        text: "!! ERRO: CHAVE DE ACESSO INVÁLIDA // PRIVILÉGIOS NEGADOS !!"
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true
        color: Theme.warmColor

        Timer {
            running: promptRoot.showFailure
            repeat: true
            interval: 400
            onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0
        }
    }
}
