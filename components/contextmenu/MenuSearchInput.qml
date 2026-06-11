pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: searchRoot

    property var menuPopup: null

    width: parent ? parent.width : 200
    height: searchRoot.menuPopup ? searchRoot.menuPopup.itemHeight + 8 : 34

    property alias inputHasFocus: textInput.focus
    property alias text: textInput.text

    function forceFocusNow() {
        textInput.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        color: searchRoot.menuPopup ? Qt.darker(searchRoot.menuPopup.menuBackgroundColor, 1.15) : "#1a1a1a"
        border.color: searchRoot.menuPopup ? searchRoot.menuPopup.menuBorderColor : "#333"
        border.width: 1

        TextInput {
            id: textInput
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            verticalAlignment: TextInput.AlignVCenter
            font.family: searchRoot.menuPopup ? searchRoot.menuPopup.labelFontFamily : "sans"
            font.pixelSize: searchRoot.menuPopup ? searchRoot.menuPopup.menuFontSize : 11
            color: searchRoot.menuPopup ? searchRoot.menuPopup.itemTextColor : "#fff"
            focus: true
            selectByMouse: true
            clip: true

            Keys.onPressed: event => {
                if (!searchRoot.menuPopup)
                    return;
                switch (event.key) {
                case Qt.Key_Down:
                case Qt.Key_Tab:
                    searchRoot.menuPopup.focusListView();
                    event.accepted = true;
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    const currentModel = searchRoot.menuPopup.getFilteredModel();
                    if (currentModel && currentModel.length > 0) {
                        const firstItem = currentModel[0];
                        const dataObj = firstItem.modelData !== undefined ? firstItem.modelData : firstItem;
                        searchRoot.menuPopup.handleItemTrigger(dataObj);
                    }
                    event.accepted = true;
                    break;
                }
            }
        }

        Text {
            anchors.fill: textInput
            anchors.leftMargin: textInput.anchors.leftMargin
            verticalAlignment: Text.AlignVCenter
            text: "Pesquisar..."
            font: textInput.font
            color: searchRoot.menuPopup ? Qt.alpha(searchRoot.menuPopup.itemTextColor, 0.4) : "#888"
            visible: textInput.text === ""
        }
    }
}
