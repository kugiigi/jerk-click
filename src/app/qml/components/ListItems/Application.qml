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

Base {
    id: rootItem

    property var appEntry

    // WORKAROUND: pageUrl needs to be a 'string', otherwise PageWrapperUtils.js
    // does not work.
    property string pageUrl
    property Component pageComponent

    height: units.gu(9)
    visible: enabled

    onClicked: {
        if (pageComponent)
            pageStack.push(pageComponent,
                           {
                               "title": appEntry.title
                           });

        if (pageUrl)
            pageStack.push(pageUrl,
                           {
                               "title": appEntry.title
                           });
    }

    Component.onCompleted: {
            captions.title.text = appEntry.title
            captions.subtitle.text = appEntry.name
            icon.source = "file://" + appEntry.directory + "/" + appEntry.icon
    }

    RowLayout {
        anchors.fill: parent
        spacing: units.gu(2)

        opacity: rootItem.enabled ? 1.0 : 0.3

        LomiriShape {
            implicitHeight: units.gu(7); implicitWidth: implicitHeight
            image: Image { id: icon }
        }

        Captions {
            id: captions

            // WORKAROUND: force Captions to set the right layout
            title.text: "Dummy text"
            subtitle.text: "Dummy text"

            Layout.fillWidth: true
        }

        Icon {
            width: units.gu(2); height: width
            name: "go-next"
        }
    }
}
