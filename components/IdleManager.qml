import QtQuick
import Quickshell.Wayland
import Quickshell.Io

Item {
id: idleManager

property bool enabledIdle: true
property LockScreen lockTarget: null

function lockScreen() {
if (lockTarget)
lockTarget.activateLock();
}

function turnOffMonitors() {
screenProcess.startDetached();
}

Process {
id: screenProcess
command: ["niri", "msg", "action", "power-off-monitors"]
}

IdleMonitor {
timeout: 300
enabled: idleManager.enabledIdle
onIsIdleChanged: if (isIdle) idleManager.lockScreen()
}

IdleMonitor {
timeout: 600
enabled: idleManager.enabledIdle
onIsIdleChanged: if (isIdle) idleManager.turnOffMonitors()
}
}
