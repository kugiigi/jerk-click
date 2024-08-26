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

    property string text: layout.title.text
    property alias iconName: icon.name
    property alias iconSource: icon.source
    property alias imageUrl: image.source
    height: Math.max(units.gu(12), layout.height)

    ListItemLayout {
        id: layout

        title {
            text: rootItem.text

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.RichText
            verticalAlignment: Text.AlignVCenter


            linkColor: theme.palette.normal.focus
            onLinkActivated: Qt.openUrlExternally(link)
        }


        Item {
            SlotsLayout.position: SlotsLayout.Leading
            width: Math.min(rootItem.width * 0.2, units.gu(8))
            height: width

            LomiriShape {
                id: shape
                anchors.fill: parent
                source: Image { id: image }
                aspect: LomiriShape.DropShadow
                visible: image.source != ""
            }

            Icon {
                id: icon
                anchors.fill: parent
                name: "dialog-warning-symbolic" // Need a warning icon with the style of security-alert

                color: theme.palette.normal.focus
                visible: image.source == ""
            }
        }
    }
}
