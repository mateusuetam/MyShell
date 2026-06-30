pragma ComponentBehavior: Bound
import QtQuick
import "../themeengine"

Item {
id: delegateRoot

required property var itemData
property int itemHeight: 26
property int separatorHeight: 8

signal triggered(var dataObj)

readonly property var safeData: delegateRoot.itemData || ({})
readonly property bool isSeparator: (safeData.isSeparator !== undefined ? safeData.isSeparator : false) || (safeData.type === "separator")
readonly property bool isEnabled: safeData.enabled !== false && !isSeparator
readonly property bool isCurrentKeyboardItem: !!delegateRoot.ListView.isCurrentItem

readonly property string labelFontFamily: TypographyRegistry.appliedFontFamily
readonly property int labelFontSize: TypographyRegistry.appliedMenuFontSize
readonly property color menuTextColor: ColorRegistry.menuTextColor
readonly property color menuTextHoverColor: ColorRegistry.menuTextHoverColor
readonly property color menuHoverColor: ColorRegistry.menuHoverColor
readonly property color menuBorderColor: ColorRegistry.menuBorderColor

width: ListView.view ? ListView.view.width : 0
height: isSeparator ? separatorHeight : itemHeight

Rectangle {
visible: delegateRoot.isSeparator
width: parent.width - 12
height: 1
anchors.centerIn: parent
color: delegateRoot.menuBorderColor
opacity: 0.6
}

Rectangle {
id: actionVisual
anchors.fill: parent
visible: !delegateRoot.isSeparator

opacity: delegateRoot.isEnabled ? 1.0 : 0.5
color: (delegateRoot.isEnabled && (mouseArea.containsMouse || delegateRoot.isCurrentKeyboardItem)) ? delegateRoot.menuHoverColor : "transparent"

Text {
anchors.fill: parent
anchors.leftMargin: 8
anchors.rightMargin: 8
verticalAlignment: Text.AlignVCenter
text: delegateRoot.safeData.text || ""
color: (delegateRoot.isEnabled && (mouseArea.containsMouse || delegateRoot.isCurrentKeyboardItem)) ? delegateRoot.menuTextHoverColor : delegateRoot.menuTextColor
font.family: delegateRoot.labelFontFamily
font.pixelSize: delegateRoot.labelFontSize
elide: Text.ElideRight
}

MouseArea {
id: mouseArea
anchors.fill: parent
enabled: delegateRoot.isEnabled
hoverEnabled: delegateRoot.isEnabled
cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
acceptedButtons: Qt.LeftButton
onPressed: {
if (delegateRoot.safeData) {
delegateRoot.triggered(delegateRoot.safeData);
}
}
}
}
}
