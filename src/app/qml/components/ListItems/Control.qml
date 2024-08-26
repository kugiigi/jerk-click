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

ListItem {
    id: rootItem
    height: Math.max(implicitHeight, layout.height)

    property alias title: layout.title
    property alias subtitle: layout.subtitle
    property alias summary: layout.summary
    default property alias control: controlContainer.data
    property alias iconName: icon.name

    ListItemLayout {
        id: layout
        anchors.centerIn: parent

        Icon {
            id: icon

            SlotsLayout.position: SlotsLayout.First
            height: units.gu(2)
            width: name ? units.gu(2) : 0
            visible: name !== ""
        }

        Item {
            id: controlContainer
            SlotsLayout.position: SlotsLayout.Last
            width: childrenRect.width
            height: childrenRect.height
            enabled: rootItem.enabled
        }
    }
}
