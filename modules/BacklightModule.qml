import QtQuick
import Quickshell.Io
import "../components/themeengine"

Item {
    id: backlightModule

    required property var globalMenu
    required property var parentWindow

    readonly property color labelColor: ColorRegistry.backlightLabelColor
    readonly property color brightnessColor: ColorRegistry.backlightBrightnessColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
    readonly property int labelFontSize: TypographyRegistry.appliedFontSize

    property int brightnessPercent: 50

    implicitWidth: backlightRow.implicitWidth
    implicitHeight: backlightModule.parentWindow ? backlightModule.parentWindow.barHeight : 30

    Process {
        id: readBrightness
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    backlightModule.brightnessPercent = val;
                }
            }
        }
        Component.onCompleted: readBrightness.running = true
    }

    Process {
        id: changeBrightness
        onExited: {
            readBrightness.running = true;
        }
    }

    Process {
        id: gammastepMenu
        command: ["sh", "-c", "$HOME/Documentos/repos/configs/scripts/redfilter.sh"]
    }

    Process {
        id: gammastepToggle
        command: ["sh", "-c", "pkill gammastep || gammastep -O 2500 &"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            let menu = backlightModule.globalMenu;
            if (menu) {
                menu.close();
            }
            mouse.accepted = true;
            if (mouse.button === Qt.LeftButton) {
                gammastepMenu.running = true;
            } else if (mouse.button === Qt.RightButton) {
                gammastepToggle.running = true;
            }
        }
        onWheel: wheel => {
            let menu = backlightModule.globalMenu;
            if (menu) {
                menu.close();
            }
            if (changeBrightness.running)
                return;
            if (wheel.angleDelta.y > 0) {
                changeBrightness.command = ["brightnessctl", "set", "+1%"];
            } else {
                changeBrightness.command = ["brightnessctl", "set", "1%-"];
            }
            changeBrightness.running = true;
        }
    }

    Row {
        id: backlightRow
        anchors.verticalCenter: parent.verticalCenter
        Text {
            id: backlightPrefix
            font.family: backlightModule.labelFontFamily
            font.pixelSize: backlightModule.labelFontSize
            color: backlightModule.labelColor
            text: "light: "
        }
        Text {
            font: backlightPrefix.font
            color: backlightModule.brightnessColor
            text: `${backlightModule.brightnessPercent}%`
        }
    }
}
