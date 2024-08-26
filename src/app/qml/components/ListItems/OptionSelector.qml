/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015 Stefano Verzegnassi

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License 3 as published by
  the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see http://www.gnu.org/licenses/.
*/

import QtQuick 2.4
import Lomiri.Components 1.3
import QtQuick.Layouts 1.1

Column {
    id: rootItem
    anchors { left: parent.left; right: parent.right }
    opacity: rootItem.enabled ? 1.0 : 0.3

    property var model
    property int selectedIndex: -1

    Repeater {
        model: rootItem.model
        delegate: ListItem {
            onClicked: rootItem.selectedIndex = model.index

            ListItemLayout {
                anchors.fill: parent
                title.text: modelData

                Icon {
                    SlotsLayout.position: SlotsLayout.Trailing
                    width: units.gu(2); height: width

                    name: "tick"
                    color: theme.palette.normal.positive
                    visible: rootItem.selectedIndex == model.index
                }
            }
        }
    }
}
