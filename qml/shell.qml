pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

ShellRoot {
    id: root

    // A rebuild must not reload the UI during password entry.
    Component.onCompleted: Quickshell.watchFiles = false

    // Shared across outputs so changing screens does not lose typed input.
    property string password: ""
    property string pendingPassword: ""
    property bool failed: false
    property string failureMessage: ""

    function submit() {
        if (pam.active || password.length === 0)
            return;
        failed = false;
        pendingPassword = password;
        password = "";
        if (!pam.start()) {
            pendingPassword = "";
            failureMessage = "Could not start authentication — check the cat-lock PAM service";
            failed = true;
        }
    }

    PamContext {
        id: pam
        config: "cat-lock"

        onPamMessage: {
            if (responseRequired) {
                respond(root.pendingPassword);
                root.pendingPassword = "";
            }
        }

        onCompleted: result => {
            root.pendingPassword = "";
            root.password = "";
            if (result === PamResult.Success) {
                // Release the compositor lock before terminating the client.
                lock.locked = false;
                Qt.quit();
            } else {
                root.failureMessage = result === PamResult.Error ? "Authentication service error — check the cat-lock PAM service" : "Authentication failed — check your password and keyboard layout";
                root.failed = true;
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            color: "black"

            Item {
                anchors.fill: parent
                focus: true

                AnimatedImage {
                    anchors.centerIn: parent
                    width: Math.min(480, parent.width * 0.6)
                    height: Math.min(480, parent.height * 0.6)
                    source: Qt.resolvedUrl("cat.gif")
                    fillMode: Image.PreserveAspectFit
                    playing: true
                    asynchronous: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 48
                    text: root.failureMessage
                    color: "#ff8080"
                    visible: root.failed
                }
                 MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.BlankCursor
                }


                // No visible password field, clipboard, or unlock shortcut.
                Keys.onPressed: event => {
                    event.accepted = true;
                    if (pam.active)
                        return;
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.submit();
                    } else if (event.key === Qt.Key_Escape || (event.key === Qt.Key_U && (event.modifiers & Qt.ControlModifier))) {
                        root.password = "";
                        root.failed = false;
                    } else if (event.key === Qt.Key_Backspace) {
                        root.password = root.password.slice(0, -1);
                        root.failed = false;
                    } else if (event.text.length > 0 && !(event.modifiers & (Qt.ControlModifier | Qt.MetaModifier)) && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
                        root.password += event.text;
                        root.failed = false;
                    }
                }
            }
        }
    }
}
