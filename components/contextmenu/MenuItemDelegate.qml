pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: delegateRoot

    required property var itemData
    required property var menuPopup

    signal triggered(var dataObj)

    readonly property var safeData: delegateRoot.itemData || ({})
    readonly property bool isEnabled: safeData.enabled !== false

    readonly property bool isSeparator: itemType === "separator"
    readonly property bool isAction: itemType === "action"
    readonly property bool isSubmenu: itemType === "submenu"
    readonly property bool isToggle: itemType === "toggle"
    readonly property bool isSlider: itemType === "slider"

    readonly property string itemType: {
        switch (true) {
        case safeData.type === "action":
        case safeData.type === "separator":
        case safeData.type === "submenu":
        case safeData.type === "toggle":
        case safeData.type === "slider":
            return safeData.type;
        case safeData.isSeparator === true:
            return "separator";
        default:
            return "action";
        }
    }

    width: parent ? parent.width : 200
    height: isSeparator ? delegateRoot.menuPopup.separatorHeight : delegateRoot.menuPopup.itemHeight

    Rectangle {
        visible: delegateRoot.isSeparator
        width: delegateRoot.width - 10
        height: 1
        anchors.centerIn: parent
        color: delegateRoot.menuPopup.menuBorderColor
    }

    Rectangle {
        visible: delegateRoot.isAction
        anchors.fill: parent
        color: mouseArea.containsMouse ? delegateRoot.menuPopup.itemHoverColor : "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            spacing: 8

            Image {
                id: itemIcon

                visible: delegateRoot.safeData.icon !== undefined && delegateRoot.safeData.icon !== ""
                width: delegateRoot.menuPopup.iconSize
                height: delegateRoot.menuPopup.iconSize
                anchors.verticalCenter: parent.verticalCenter
                source: delegateRoot.safeData.icon || ""
                sourceSize.width: delegateRoot.menuPopup.iconSize
                sourceSize.height: delegateRoot.menuPopup.iconSize
            }

            Text {
                id: itemText

                text: delegateRoot.safeData.text || ""
                width: delegateRoot.width - (delegateRoot.menuPopup.iconSize + 24)
                anchors.verticalCenter: parent.verticalCenter
                color: mouseArea.containsMouse ? delegateRoot.menuPopup.itemTextHoverColor : delegateRoot.menuPopup.itemTextColor
                font.family: delegateRoot.menuPopup.labelFontFamily
                font.pixelSize: delegateRoot.menuPopup.menuFontSize

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            enabled: delegateRoot.isEnabled
            hoverEnabled: delegateRoot.isEnabled
            cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                delegateRoot.triggered(delegateRoot.safeData);
            }
        }
    }
}
