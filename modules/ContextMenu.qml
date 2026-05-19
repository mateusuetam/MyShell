import QtQuick
import Quickshell

PopupWindow {
    id: menuPopup

    property var menuModel: null

    implicitWidth: 200
    implicitHeight: menuLayout.implicitHeight + 12
    grabFocus: true

    readonly property string backgroundColor: "#282828"
    readonly property string hoverColor: "#3c3836"
    readonly property string textColor: "#ebdbb2"
    readonly property string borderColor: "#504945"
    readonly property string accentColor: "#fe8019"

    QsMenuOpener {
        id: menuOpener
        menu: menuPopup.menuModel
    }

    Rectangle {
        anchors.fill: parent
        color: menuPopup.backgroundColor
        border.color: menuPopup.borderColor
        border.width: 1

        Column {
            id: menuLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 6
            spacing: 2

            Repeater {
                model: menuOpener.children

                delegate: Item {
                    width: menuLayout.width

                    readonly property bool isSep: modelData.isSeparator
                    height: isSep ? 8 : 26

                    Rectangle {
                        visible: parent.isSep
                        width: parent.width - 10
                        height: 1
                        color: menuPopup.borderColor
                        anchors.centerIn: parent
                    }

                    Rectangle {
                        visible: !parent.isSep
                        anchors.fill: parent
                        color: mouseArea.containsMouse ? menuPopup.hoverColor : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 8

                            Image {
                                visible: modelData.icon !== ""
                                width: 14
                                height: 14
                                anchors.verticalCenter: parent.verticalCenter
                                source: modelData.icon
                                sourceSize.width: 14
                                sourceSize.height: 14
                            }

                            Text {
                                text: modelData.text
                                color: mouseArea.containsMouse ? menuPopup.accentColor : menuPopup.textColor
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: modelData.enabled
                            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: {
                                if (hoverEnabled) {
                                    if (typeof modelData.triggered === "function") {
                                        modelData.triggered();
                                    }

                                    menuPopup.visible = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
