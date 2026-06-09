pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray

Item {
    id: trayModule

    required property var globalMenu
    required property var parentWindow

    readonly property int iconSize: 20
    readonly property int itemSpacing: 10

    implicitWidth: trayLayout.implicitWidth
    implicitHeight: trayModule.parentWindow ? trayModule.parentWindow.barHeight : 30

    visible: !!SystemTray.items

    Row {
        id: trayLayout
        height: parent.height
        spacing: trayModule.itemSpacing
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: trayItemDelegate

                width: trayModule.iconSize
                height: trayModule.iconSize
                anchors.verticalCenter: parent.verticalCenter

                required property var modelData
                readonly property var trayItem: trayItemDelegate.modelData

                Image {
                    anchors.fill: parent
                    source: trayItemDelegate.trayItem?.icon ?? ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    sourceSize.width: trayModule.iconSize
                    sourceSize.height: trayModule.iconSize
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: mouse => {
                        let menu = trayModule.globalMenu;
                        if (menu) {
                            menu.close();
                        }
                        mouse.accepted = true;
                        let item = trayItemDelegate.trayItem;
                        if (!item)
                            return;
                        if (mouse.button === Qt.LeftButton) {
                            item.activate();
                        } else if (mouse.button === Qt.RightButton && item.hasMenu && item.menu && menu) {
                            menu.openMenu(trayModule.parentWindow, trayItemDelegate, item.menu);
                        }
                    }
                }
            }
        }
    }
}
