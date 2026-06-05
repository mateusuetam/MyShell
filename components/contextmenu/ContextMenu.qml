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
    readonly property int verticalOffset: 5
    property var _pendingModel: null
    property var _pendingWindow: null
    property var _pendingAnchorItem: null
    property int _pendingX: 0
    property int _pendingY: 0
    property bool _isAnchorMode: false

    readonly property var _self: menuPopup

    implicitWidth: menuPopup.menuWidth
    implicitHeight: menuView.contentHeight + 12
    grabFocus: true

    signal itemDataActionTriggered(string actionType, var data)

    onVisibleChanged: {
        if (!visible) {
            _self.anchor.window = null;
        }
    }

    Timer {
        id: repositionTimer

        interval: 32
        repeat: false

        onTriggered: {
            menuPopup.menuModel = menuPopup._pendingModel;
            menuPopup._self.anchor.window = menuPopup._pendingWindow;

            if (menuPopup._isAnchorMode) {
                if (!menuPopup._pendingAnchorItem)
                    return;
                const windowPos = menuPopup._pendingAnchorItem.mapToItem(null, 0, menuPopup._pendingAnchorItem.height);
                const newX = windowPos.x - (menuPopup.implicitWidth / 2) + (menuPopup._pendingAnchorItem.width / 2);
                const newY = windowPos.y + menuPopup.verticalOffset;
                menuPopup._self.anchor.rect = Qt.rect(newX, newY, menuPopup._pendingAnchorItem.width, 1);
            } else {
                menuPopup._self.anchor.rect = Qt.rect(menuPopup._pendingX, menuPopup._pendingY, 1, 1);
            }
            menuPopup.visible = true;
        }
    }

    function close() {
        menuPopup.visible = false;
    }

    function openMenu(targetWindow, anchorItem, menuModel) {
        if (!anchorItem)
            return;
        menuPopup.visible = false;
        menuPopup._pendingModel = menuModel;
        menuPopup._pendingWindow = targetWindow;
        menuPopup._pendingAnchorItem = anchorItem;
        menuPopup._isAnchorMode = true;
        repositionTimer.restart();
    }

    function openAtPosition(targetWindow, x, y, menuModel) {
        if (!targetWindow)
            return;
        menuPopup.visible = false;
        menuPopup._pendingModel = menuModel;
        menuPopup._pendingWindow = targetWindow;
        menuPopup._pendingX = x;
        menuPopup._pendingY = y;
        menuPopup._isAnchorMode = false;
        repositionTimer.restart();
    }

    QsMenuOpener {
        id: menuOpener
        menu: Array.isArray(menuPopup.menuModel) ? null : menuPopup.menuModel
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
            interactive: false
            model: Array.isArray(menuPopup.menuModel) ? menuPopup.menuModel : menuOpener.children

            delegate: Item {
                id: contextMenuItemDelegate

                width: menuView.width
                required property var modelData
                readonly property bool isSep: contextMenuItemDelegate.modelData.isSeparator || false
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
                            visible: contextMenuItemDelegate.modelData.icon !== undefined && contextMenuItemDelegate.modelData.icon !== ""
                            width: menuPopup.iconSize
                            height: menuPopup.iconSize
                            anchors.verticalCenter: parent.verticalCenter
                            source: contextMenuItemDelegate.modelData.icon || ""
                            sourceSize.width: menuPopup.iconSize
                            sourceSize.height: menuPopup.iconSize
                        }

                        Text {
                            text: contextMenuItemDelegate.modelData.text || ""
                            color: mouseArea.containsMouse ? menuPopup.itemTextHoverColor : menuPopup.itemTextColor
                            font.family: menuPopup.labelFontFamily
                            font.pixelSize: menuPopup.menuFontSize
                            anchors.verticalCenter: parent.verticalCenter
                            width: contextMenuItemDelegate.width - (menuPopup.iconSize + 24)
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: contextMenuItemDelegate.modelData.enabled !== false
                        cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (!hoverEnabled)
                                return;

                            var dataObj = contextMenuItemDelegate.modelData;

                            if (dataObj.actionType !== undefined) {
                                menuPopup.itemDataActionTriggered(dataObj.actionType, dataObj.actionData);
                            }

                            if (typeof dataObj.triggered === "function") {
                                dataObj.triggered();
                            } else if (typeof dataObj.trigger === "function") {
                                dataObj.trigger();
                            }

                            if (dataObj.preventClose !== true)
                                menuPopup.visible = false;
                        }
                    }
                }
            }
        }
    }
}
