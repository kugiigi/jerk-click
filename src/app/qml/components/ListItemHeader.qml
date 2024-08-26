import QtQuick 2.4
import Lomiri.Components 1.3

ListItem {
    id: headerListItem

    property string title

    height: units.gu(4)
    Label {
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: units.gu(2) }
        text: title
        font.bold: false
    }
}
