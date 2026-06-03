pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../theme"

PopupWindow {
    id: menuPopup

    property var menuModel: null

    implicitWidth: 200
    implicitHeight: menuView.contentHeight + 12
    grabFocus: true

    QsMenuOpener {
        id: menuOpener
        menu: menuPopup.menuModel
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
        border.color: Theme.borderColor
        border.width: 1

        ListView {
            id: menuView
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            model: menuOpener.children

            delegate: Item {
                id: contextMenuItemDelegate
                width: menuView.width

                required property var modelData
                readonly property bool isSep: contextMenuItemDelegate.modelData.isSeparator

                height: isSep ? 8 : 26

                Rectangle {
                    visible: contextMenuItemDelegate.isSep
                    width: contextMenuItemDelegate.width - 10
                    height: 1
                    color: Theme.borderColor
                    anchors.centerIn: parent
                }

                Rectangle {
                    visible: !contextMenuItemDelegate.isSep
                    anchors.fill: parent
                    color: mouseArea.containsMouse ? Theme.hoverColor : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8

                        Image {
                            visible: contextMenuItemDelegate.modelData.icon !== ""
                            width: 14
                            height: 14
                            anchors.verticalCenter: parent.verticalCenter
                            source: contextMenuItemDelegate.modelData.icon
                            sourceSize.width: 14
                            sourceSize.height: 14
                        }

                        Text {
                            text: contextMenuItemDelegate.modelData.text
                            color: mouseArea.containsMouse ? Theme.flashyColor : Theme.textColor
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: contextMenuItemDelegate.modelData.enabled
                        cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (hoverEnabled) {
                                if (typeof contextMenuItemDelegate.modelData.triggered === "function") {
                                    contextMenuItemDelegate.modelData.triggered();
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
