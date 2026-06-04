pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../themeengine"

PopupWindow {
    id: menuPopup

    readonly property color menuBackgroundColor: ColorRegistry.menuBackgroundColor
    readonly property color menuBorderColor: ColorRegistry.menuBorderColor
    readonly property color itemTextColor: ColorRegistry.menuTextColor
    readonly property color itemHoverColor: ColorRegistry.menuHoverColor
    readonly property color itemTextHoverColor: ColorRegistry.menuTextHoverColor
    readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily

    readonly property int menuWidth: 200
    readonly property int itemHeight: 26
    readonly property int separatorHeight: 8
    readonly property int iconSize: 14
    readonly property int menuFontSize: 11

    property var menuModel: null

    implicitWidth: menuPopup.menuWidth
    implicitHeight: menuView.contentHeight + 12
    grabFocus: true

    QsMenuOpener {
        id: menuOpener
        menu: menuPopup.menuModel
    }

    Rectangle {
        anchors.fill: parent
        color: menuPopup.menuBackgroundColor
        border.color: menuPopup.menuBorderColor
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

                height: isSep ? menuPopup.separatorHeight : menuPopup.itemHeight

                Rectangle {
                    visible: contextMenuItemDelegate.isSep
                    width: contextMenuItemDelegate.width - 10
                    height: 1
                    color: menuPopup.menuBorderColor
                    anchors.centerIn: parent
                }

                Rectangle {
                    visible: !contextMenuItemDelegate.isSep
                    anchors.fill: parent
                    color: mouseArea.containsMouse ? menuPopup.itemHoverColor : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        spacing: 8

                        Image {
                            visible: contextMenuItemDelegate.modelData.icon !== ""
                            width: menuPopup.iconSize
                            height: menuPopup.iconSize
                            anchors.verticalCenter: parent.verticalCenter
                            source: contextMenuItemDelegate.modelData.icon
                            sourceSize.width: menuPopup.iconSize
                            sourceSize.height: menuPopup.iconSize
                        }

                        Text {
                            text: contextMenuItemDelegate.modelData.text
                            color: mouseArea.containsMouse ? menuPopup.itemTextHoverColor : menuPopup.itemTextColor
                            font.family: menuPopup.labelFontFamily
                            font.pixelSize: menuPopup.menuFontSize
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
