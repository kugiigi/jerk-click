import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.1

ListItem {
    id: rootItem

    property string text
    property alias iconName: icon.name
    property alias title: layout.title
    property alias subtitle: layout.subtitle
    property alias summary: layout.summary
    property url url

    height: Math.max(implicitHeight, layout.height)

    ListItemLayout {
        id: layout

        anchors.centerIn: parent

        title.text: rootItem.text

        Icon {
            id: icon

            SlotsLayout.position: SlotsLayout.First
            height: units.gu(2)
            width: name ? units.gu(2) : 0
            visible: name !== ""
        }

        Icon {
            SlotsLayout.position: SlotsLayout.Last
            width: units.gu(2); height: width
            name: "external-link"
        }
    }

    onClicked: Qt.openUrlExternally(rootItem.url)
}
