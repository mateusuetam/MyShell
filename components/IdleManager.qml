import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: idleManager

    property bool enabled: true
    property var lockTarget: null

    Process {
        id: screenProcess
        command: ["niri", "msg", "action", "power-off-monitors"]
    }

    function lockScreen() {
        if (lockTarget != null) {
            lockTarget.activateLock();
        }
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
            if (isIdle)
                idleManager.lockScreen();
        }
    }

    IdleMonitor {
        id: screenMonitor
        timeout: 600
        enabled: idleManager.enabled
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle)
                idleManager.turnOffMonitors();
        }
    }
}
