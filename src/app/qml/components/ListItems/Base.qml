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

ListItem {
    id: rootItem

    height: units.gu(7)
    width: parent.width
    color: "transparent"

    signal singleClicked
    signal doubleClicked

    onClicked: {
        if (!timer.running) {
            timer.restart()
        } else {
            timer.stop()
            rootItem.doubleClicked()
        }
    }

    default property alias contents: container.data
    Item {
        id: container
        anchors.fill: parent
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
    }

    /*
      ListItem from Lomiri.Components 1.2 does not handle double-click.
      Use a timer to simulate it.
    */
    Timer {
        id: timer
        interval: 200

        onTriggered: rootItem.singleClicked()
    }
}
