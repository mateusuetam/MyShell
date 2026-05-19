import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: trayModule

    property var parentWindow: null

    implicitWidth: trayLayout.implicitWidth
    implicitHeight: 30

    visible: SystemTray.items !== undefined && SystemTray.items !== null

    ContextMenu {
        id: customMenu
    }

    Row {
        id: trayLayout
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItemDelegate
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                readonly property var trayItem: modelData

                Image {
                    anchors.fill: parent
                    source: trayItem && trayItem.icon ? trayItem.icon : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: mouse => {
                        if (!trayItem)
                            return;

                        if (mouse.button === Qt.LeftButton) {
                            trayItem.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            if (trayItem.hasMenu && trayItem.menu) {
                                customMenu.menuModel = trayItem.menu;
                                var windowPos = trayItemDelegate.mapToItem(null, 0, trayItemDelegate.height);
                                customMenu.anchor.window = trayModule.parentWindow;
                                customMenu.anchor.rect.x = windowPos.x - (customMenu.implicitWidth / 2) + (trayItemDelegate.width / 2);
                                customMenu.anchor.rect.y = windowPos.y + 5;
                                customMenu.visible = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
