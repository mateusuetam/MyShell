pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: delegateRoot

    required property var itemData
    required property var menuPopup

    signal triggered(var dataObj)

    readonly property var safeData: delegateRoot.itemData || ({})
    readonly property bool isEnabled: safeData.enabled !== false

    readonly property string itemType: {
        switch (true) {
        case safeData.type === "action":
        case safeData.type === "separator":
        case safeData.type === "submenu":
        case safeData.type === "toggle":
            return safeData.type;
        case safeData.isSeparator === true:
            return "separator";
        default:
            return "action";
        }
    }

    readonly property bool isSeparator: itemType === "separator"
    readonly property bool isAction: itemType === "action"
    readonly property bool isSubmenu: itemType === "submenu"
    readonly property bool isToggle: itemType === "toggle"

    width: parent ? parent.width : 0
    height: isSeparator ? delegateRoot.menuPopup.separatorHeight : delegateRoot.menuPopup.itemHeight

    Component {
        id: separatorComponent
        MenuSeparator {
            menuPopup: delegateRoot.menuPopup
        }
    }

    Component {
        id: actionComponent
        MenuAction {
            safeData: delegateRoot.safeData
            menuPopup: delegateRoot.menuPopup
            isEnabled: delegateRoot.isEnabled
            isSubmenu: delegateRoot.isSubmenu
            isToggle: delegateRoot.isToggle

            onTriggered: dataObj => delegateRoot.triggered(dataObj)
        }
    }

    Loader {
        id: delegateLoader
        anchors.fill: parent
        sourceComponent: delegateRoot.isSeparator ? separatorComponent : actionComponent
    }
}
