import QtQuick
import Quickshell.Services.Mpris
import "../components/theme"

Item {
    id: mprisModule

    readonly property var activePlayer: mprisModule.getRealActivePlayer()

    function getRealActivePlayer() {
        var list = Mpris.players.values;
        if (!list || list.length === 0)
            return null;
        for (var i = 0; i < list.length; i++) {
            var p = list[i];
            if (p && p.dbusName && p.dbusName.indexOf("playerctld") !== -1) {
                continue;
            }
            if (p && p.trackTitle !== "") {
                return p;
            }
        }
        return null;
    }

    implicitWidth: mprisText.implicitWidth
    implicitHeight: 30
    visible: activePlayer !== null

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            if (!mprisModule.activePlayer)
                return;
            if (mouse.button === Qt.LeftButton && mprisModule.activePlayer.canTogglePlaying) {
                mprisModule.activePlayer.togglePlaying();
            } else if (mouse.button === Qt.RightButton && mprisModule.activePlayer.canGoNext) {
                mprisModule.activePlayer.next();
            } else if (mouse.button === Qt.MiddleButton && mprisModule.activePlayer.canGoPrevious) {
                mprisModule.activePlayer.previous();
            }
        }
    }

    Text {
        id: mprisText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        anchors.verticalCenter: parent.verticalCenter
        color: (mprisModule.activePlayer && mprisModule.activePlayer.isPlaying) ? Theme.positiveColor : Theme.activeColor
        text: {
            if (!mprisModule.activePlayer || !mprisModule.activePlayer.trackTitle)
                return "";
            var title = mprisModule.activePlayer.trackTitle;
            var artist = mprisModule.activePlayer.trackArtist || "Desconhecido";
            var icon = mprisModule.activePlayer.isPlaying ? "||" : ">";
            return `${icon} ${title} - ${artist}`;
        }
    }
}
