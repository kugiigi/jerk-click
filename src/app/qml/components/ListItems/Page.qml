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

    // WORKAROUND: pageUrl needs to be a 'string', otherwise PageWrapperUtils.js
    // does not work.
    property string pageUrl
    property Component pageComponent
    property string text
    property alias iconName: icon.name
    property alias title: layout.title
    property alias subtitle: layout.subtitle
    property alias summary: layout.summary
    property var pushProperties

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
            name: "go-next"
        }
    }

    QtObject {
        id: d

        /*
          The title of the page is supposed to be single-line.
          Since we also use multi-line string for rootItem.text property,
          we use only the first line of the string, in order to avoid
          something *very* ugly.
         */
        property string pageTitle: rootItem.text.split("\n")[0]
    }

    onClicked: {
        if (pageComponent)
            pageStack.push(pageComponent, pushProperties);

        if (pageUrl)
            pageStack.push(pageUrl, pushProperties);
    }
}
