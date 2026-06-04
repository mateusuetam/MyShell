import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import "../themeengine"

ColumnLayout {
    id: promptRoot

    readonly property color labelColor: ColorRegistry.lockPromptLabelColor
    readonly property color inputActiveColor: ColorRegistry.lockPromptInputActiveColor
    readonly property color inputInactiveColor: ColorRegistry.lockPromptInputInactiveColor
    readonly property color errorColor: ColorRegistry.lockPromptErrorColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: 16
    readonly property int inputFontSize: 22
    readonly property int errorFontSize: 14
    readonly property int inputWidth: 400

    readonly property string loginText: "NOSTROMO_LOGIN_node7 > INSIRA A CHAVE DE ACESSO:"
    readonly property string authInProgressText: "AUTENTICANDO DIRETÓRIO DE SESSÃO..."
    readonly property string errorText: "!! ERRO: CHAVE DE ACESSO INVÁLIDA // PRIVILÉGIOS NEGADOS !!"

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
        text: promptRoot.unlockInProgress ? promptRoot.authInProgressText : promptRoot.loginText
        font.family: promptRoot.labelFontFamily
        font.pixelSize: promptRoot.labelFontSize
        color: promptRoot.labelColor
    }

    RowLayout {
        spacing: 0

        TextField {
            id: passwordBox
            implicitWidth: promptRoot.inputWidth
            padding: 0

            focus: true
            enabled: !promptRoot.unlockInProgress
            echoMode: TextInput.Password

            cursorDelegate: Item {}

            font.family: promptRoot.labelFontFamily
            font.pixelSize: promptRoot.inputFontSize

            color: promptRoot.inputActiveColor
            background: Item {}

            onTextChanged: promptRoot.textChanged(text)
            onAccepted: promptRoot.accepted()
        }

        Text {
            text: "▒"
            font.pixelSize: promptRoot.inputFontSize
            color: promptRoot.inputActiveColor
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
        implicitWidth: promptRoot.inputWidth + 15
        implicitHeight: 2
        color: passwordBox.activeFocus ? promptRoot.inputActiveColor : promptRoot.inputInactiveColor
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: promptRoot.showFailure
        text: promptRoot.errorText
        font.family: promptRoot.labelFontFamily
        font.pixelSize: promptRoot.errorFontSize
        font.bold: true
        color: promptRoot.errorColor

        Timer {
            running: promptRoot.showFailure
            repeat: true
            interval: 400
            onTriggered: parent.opacity = parent.opacity === 1.0 ? 0.3 : 1.0
        }
    }
}
