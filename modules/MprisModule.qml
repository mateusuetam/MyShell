import QtQuick
import Quickshell.Services.Mpris

Item {
    id: mprisModule

    readonly property string playingColor: "#b8bb26"
    readonly property string pausedColor: "#8ec07c"
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (!mprisModule.activePlayer)
                return;
            if (mouse.button === Qt.LeftButton && mprisModule.activePlayer.canTogglePlaying) {
                mprisModule.activePlayer.togglePlaying();
            } else if (mouse.button === Qt.RightButton && mprisModule.activePlayer.canGoNext) {
                mprisModule.activePlayer.next();
            }
        }
    }

    Text {
        id: mprisText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
        color: (mprisModule.activePlayer && mprisModule.activePlayer.isPlaying) ? mprisModule.playingColor : mprisModule.pausedColor
        text: {
            if (!mprisModule.activePlayer || !mprisModule.activePlayer.trackTitle)
                return "";
            var title = mprisModule.activePlayer.trackTitle;
            var artist = mprisModule.activePlayer.trackArtist || "Desconhecido";
            var icon = mprisModule.activePlayer.isPlaying ? "playing:" : "paused:";
            return `${icon} ${title} - ${artist}`;
        }
    }
}
