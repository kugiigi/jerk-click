import QtQuick 2.12
import Lomiri.Components 1.3
import QtGraphicalEffects 1.12

LinearGradient  {
    id: rootItem

    property Flickable view
    property int edge: Qt.LeftEdge
    readonly property bool isHorizontal: edge == Qt.LeftEdge || edge == Qt.RightEdge
    readonly property bool isStartOfView: edge == Qt.LeftEdge || edge == Qt.TopEdge

    width: units.gu(5)
    visible: opacity > 0
    opacity: {
        if (view == undefined)
            return 0

        switch (edge) {
            case Qt.LeftEdge:
            case Qt.TopEdge:
                return !view.atXBeginning ? 1 : 0
                break
            case Qt.RightEdge:
                return !view.atXEnd ? 1 : 0
                break
            default:
                return 0
        }
    }

    gradient: Gradient {
        orientation: rootItem.isHorizontal ? Gradient.Horizontal : Gradient.Vertical
        GradientStop { position: rootItem.isStartOfView ? 0.0 : 1.0; color: "#87000000" }
        GradientStop { position: rootItem.isStartOfView ? 1.0 : 0.0; color: "#00000000" }
    }

    Behavior on opacity { LomiriNumberAnimation { duration: LomiriAnimation.BriskDuration } }
}
