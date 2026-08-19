pragma ComponentBehavior: Bound
import QtQuick
import "../core"

Item {
id: delegateRoot

required property var itemData
property int itemHeight: 26
property int separatorHeight: 8

signal triggered(var dataObj)

readonly property var safeData: delegateRoot.itemData || ({})
readonly property bool isSeparator: !!safeData.isSeparator || safeData.type === "separator"
readonly property bool isGridRow: safeData.type === "gridRow"
readonly property bool isSplitAction: safeData.type === "splitAction"
readonly property bool isInteractiveDefault: safeData.enabled !== false && !isSeparator && !isGridRow && !isSplitAction
readonly property bool isEnabled: safeData.enabled !== false && !isSeparator
readonly property bool isCurrentKeyboardItem: !!delegateRoot.ListView.isCurrentItem
readonly property bool isHighlighted: isInteractiveDefault && (mouseArea.containsMouse || isCurrentKeyboardItem)

width: ListView.view ? ListView.view.width : 0
height: isSeparator ? separatorHeight : itemHeight

Rectangle {
visible: delegateRoot.isSeparator
width: parent.width - 12
height: 1
anchors.centerIn: parent
color: ThemeEngine.dynamicBorderColor
opacity: 0.6
}

Rectangle {
id: actionVisual
anchors.fill: parent
visible: !delegateRoot.isSeparator && !delegateRoot.isGridRow && !delegateRoot.isSplitAction
opacity: delegateRoot.isEnabled ? 1.0 : 0.5
color: delegateRoot.isHighlighted ? ThemeEngine.palette.menuHoverColor : "transparent"
radius: ThemeEngine.palette.shellRadius

Text {
anchors.fill: parent
anchors.leftMargin: 8
anchors.rightMargin: 8
verticalAlignment: Text.AlignVCenter
horizontalAlignment: delegateRoot.safeData.align === "center" ? Text.AlignHCenter : Text.AlignLeft
text: delegateRoot.safeData.text || ""
color: delegateRoot.isHighlighted ? ThemeEngine.palette.menuTextHoverColor : ThemeEngine.palette.menuTextColor
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedMenuFontSize
elide: delegateRoot.safeData.align === "center" ? Text.ElideNone : Text.ElideRight
}

MouseArea {
id: mouseArea
anchors.fill: parent
enabled: delegateRoot.isInteractiveDefault
hoverEnabled: delegateRoot.isInteractiveDefault
cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
acceptedButtons: Qt.LeftButton
onPressed: delegateRoot.triggered(delegateRoot.safeData)
}
}

Row {
anchors.fill: parent
anchors.leftMargin: 4
anchors.rightMargin: 4
visible: delegateRoot.isGridRow
spacing: 0

Repeater {
model: delegateRoot.isGridRow ? delegateRoot.safeData.items : 0

delegate: Item {
id: gridDelegate

required property var modelData

width: (delegateRoot.width - 8) / 7
height: delegateRoot.height

Rectangle {
anchors.centerIn: parent
width: parent.height - 2
height: parent.height - 2
radius: ThemeEngine.palette.shellRadius
color: gridDelegate.modelData?.isToday ? ThemeEngine.palette.menuHoverColor : "transparent"

Text {
anchors.fill: parent
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
text: typeof gridDelegate.modelData === "string" ? gridDelegate.modelData : (gridDelegate.modelData?.text ?? "")
color: gridDelegate.modelData?.isToday ? ThemeEngine.palette.menuTextHoverColor : ThemeEngine.palette.menuTextColor
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedMenuFontSize - 1
fontSizeMode: Text.HorizontalFit
minimumPixelSize: 8
}
}
}
}
}

Row {
anchors.fill: parent
visible: delegateRoot.isSplitAction
spacing: 4

Repeater {
model: delegateRoot.isSplitAction ? delegateRoot.safeData.actions : 0

delegate: Rectangle {
id: actionDelegate

required property var modelData

width: (delegateRoot.width - 4) / 2
height: delegateRoot.height
radius: ThemeEngine.palette.shellRadius
color: splitMouse.containsMouse ? ThemeEngine.palette.menuHoverColor : "transparent"

Text {
anchors.fill: parent
anchors.leftMargin: 4
anchors.rightMargin: 4
horizontalAlignment: Text.AlignHCenter
verticalAlignment: Text.AlignVCenter
text: actionDelegate.modelData?.text ?? ""
color: splitMouse.containsMouse ? ThemeEngine.palette.menuTextHoverColor : ThemeEngine.palette.menuTextColor
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedMenuFontSize - 1
elide: Text.ElideRight
}

MouseArea {
id: splitMouse
anchors.fill: parent
hoverEnabled: true
cursorShape: Qt.PointingHandCursor
onPressed: {
if (actionDelegate.modelData?.onTrigger) actionDelegate.modelData.onTrigger();
}
}
}
}
}
}
