import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion

ColumnLayout {
    id: promptRoot
    Layout.alignment: Qt.AlignHCenter
    Layout.bottomMargin: 100
    spacing: 15

    property bool unlockInProgress: false
    property bool showFailure: false

    signal textChanged(string val)
    signal accepted

    function clearText() {
        passwordBox.text = "";
    }

    Text {
        text: promptRoot.unlockInProgress ? "AUTENTICANDO DIRETÓRIO DE SESSÃO..." : "NOSTROMO_LOGIN_node7 > INSIRA A CHAVE DE ACESSO:"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        color: "#fabd2f"
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

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22

            color: "#8ec07c"
            background: Item {}

            onTextChanged: promptRoot.textChanged(this.text)
            onAccepted: promptRoot.accepted()
        }

        Text {
            text: "▒"
            font.pixelSize: 22
            color: "#8ec07c"
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
        height: 2
        color: passwordBox.activeFocus ? "#8ec07c" : "#504945"
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: promptRoot.showFailure
        text: "!! ERRO: CHAVE DE ACESSO INVÁLIDA // PRIVILÉGIOS NEGADOS !!"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.bold: true
        color: "#fb4934"

        Timer {
            running: promptRoot.showFailure
            repeat: true
            interval: 400
            onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0
        }
    }
}
