pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: sliderRoot

    required property var safeData
    required property var menuPopup
    required property bool isEnabled

    property real value: safeData.value !== undefined ? safeData.value : 0.5
    property real minValue: safeData.minValue !== undefined ? safeData.minValue : 0.0
    property real maxValue: safeData.maxValue !== undefined ? safeData.maxValue : 1.0

    function updateValueFromMouse(mouseX, trackWidth) {
        if (trackWidth <= 0)
            return;

        let pct = Math.max(0, Math.min(1, mouseX / trackWidth));
        sliderRoot.value = sliderRoot.minValue + pct * (sliderRoot.maxValue - sliderRoot.minValue);

        if (typeof sliderRoot.safeData.onValueChanged === "function") {
            sliderRoot.safeData.onValueChanged(sliderRoot.value);
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Image {
            id: sliderIcon
            visible: !!sliderRoot.safeData.icon
            width: sliderRoot.menuPopup.iconSize
            height: sliderRoot.menuPopup.iconSize
            anchors.verticalCenter: parent.verticalCenter
            source: sliderRoot.safeData.icon || ""
            sourceSize.width: sliderRoot.menuPopup.iconSize
            sourceSize.height: sliderRoot.menuPopup.iconSize
        }

        Item {
            width: parent.width - (sliderIcon.visible ? sliderIcon.width + parent.spacing : 0)
            height: parent.height

            Rectangle {
                id: trackBg
                width: parent.width
                height: 4
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.darker(sliderRoot.menuPopup.menuBorderColor, 1.2)
            }

            Rectangle {
                id: trackFill
                readonly property real range: sliderRoot.maxValue - sliderRoot.minValue
                width: trackBg.width * (range > 0 ? (sliderRoot.value - sliderRoot.minValue) / range : 0)
                height: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: trackBg.left
                color: sliderRoot.menuPopup.itemTextHoverColor
            }

            Rectangle {
                width: 12
                height: 12
                anchors.verticalCenter: parent.verticalCenter
                x: trackFill.width - (width / 2)
                color: sliderRoot.menuPopup.itemTextColor
                border.color: sliderRoot.menuPopup.menuBackgroundColor
                border.width: 1
            }

            MouseArea {
                anchors.fill: parent
                enabled: sliderRoot.isEnabled
                onPressed: mouse => sliderRoot.updateValueFromMouse(mouse.x, width)
                onPositionChanged: mouse => sliderRoot.updateValueFromMouse(mouse.x, width)
            }
        }
    }
}
