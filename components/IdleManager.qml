import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: idleManager

    property bool enabled: true

    Process {
        id: lockProcess
        command: ["swaylock", "-f"]
    }

    Process {
        id: screenProcess
        command: ["niri", "msg", "action", "power-off-monitors"]
    }

    function lockScreen() {
        lockProcess.startDetached();
    }

    function turnOffMonitors() {
        screenProcess.startDetached();
    }

    IdleMonitor {
        id: lockMonitor
        timeout: 300
        enabled: idleManager.enabled
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle) {
                idleManager.lockScreen();
            }
        }
    }

    IdleMonitor {
        id: screenMonitor
        timeout: 600
        enabled: idleManager.enabled
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle) {
                idleManager.turnOffMonitors();
            }
        }
    }
}
