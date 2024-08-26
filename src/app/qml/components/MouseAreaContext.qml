import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2

MouseArea {

    signal trigger(real mouseX, real mouseY)

    acceptedButtons: Qt.RightButton
    propagateComposedEvents: true

    onClicked: {
        if (mouse.button == Qt.RightButton) {
            trigger(mouseX, mouseY)
        }
    }
}
