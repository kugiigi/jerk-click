import QtQuick 2.12
import Lomiri.Components 1.3

ListItem {
    id: switchItem

    property string text
    property alias checked: switchObj.checked

    height: layout.height
    divider.visible: false
    onClicked: switchObj.checked = !switchObj.checked
    ListItemLayout {
        id: layout
        title.text: switchItem.text
        Switch {
            id: switchObj
            SlotsLayout.position: SlotsLayout.Trailing;
            checked: true
        }
    }
}
