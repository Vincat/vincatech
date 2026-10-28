import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 36
        color: "#20242c"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Repeater {
                model: Hyprland.workspaces

                Rectangle {
                    id: workspaceButton
                    required property var modelData

                    width: 32
                    height: 26
                    radius: 5
                    color: modelData.focused ? "#82aaff" : "#343b49"

                    Text {
                        anchors.centerIn: parent
                        text: workspaceButton.modelData.name
                        color: workspaceButton.modelData.focused
                               ? "#20242c" : "#eeeeee"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: workspaceButton.modelData.activate()
                    }
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "ddd d MMM  |  HH:mm")
            color: "#eeeeee"
            font.pixelSize: 15
        }
    }
}
