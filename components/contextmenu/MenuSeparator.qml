pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: separatorRoot

    required property var menuPopup

    Rectangle {
        width: parent.width - 10
        height: 1
        anchors.centerIn: parent
        color: separatorRoot.menuPopup.menuBorderColor
    }
}
