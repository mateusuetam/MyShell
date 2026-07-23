pragma ComponentBehavior: Bound
import QtQuick
import "../core"

Item {
id: searchRoot

property int itemHeight: 26
property alias text: textInput.text

signal navigationDownRequested
signal actionTriggeredRequested

function forceFocusNow() {
textInput.forceActiveFocus();
}

width: parent ? parent.width : 200
height: itemHeight + 8

Rectangle {
anchors.fill: parent
anchors.margins: 4
color: Qt.darker(ThemeEngine.palette.menuBackgroundColor, 1.15)
border.color: ThemeEngine.palette.menuBorderColor
border.width: 1

TextInput {
id: textInput
anchors.left: parent.left
anchors.right: parent.right
anchors.leftMargin: 8
anchors.rightMargin: 8
anchors.verticalCenter: parent.verticalCenter
font.family: ThemeEngine.appliedFontFamily
font.pixelSize: ThemeEngine.appliedMenuFontSize
color: ThemeEngine.palette.menuTextColor
focus: true
selectByMouse: true
clip: true

Keys.onPressed: event => {
switch (event.key) {
case Qt.Key_Down:
case Qt.Key_Tab:
searchRoot.navigationDownRequested();
event.accepted = true;
break;
case Qt.Key_Return:
case Qt.Key_Enter:
searchRoot.actionTriggeredRequested();
event.accepted = true;
break;
}
}
}

Text {
anchors.fill: textInput
verticalAlignment: Text.AlignVCenter
text: "Pesquisar..."
font: textInput.font
color: ThemeEngine.palette.menuTextColor
opacity: 0.4
visible: textInput.text === ""
}
}
}
