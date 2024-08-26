/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015, 2016 Stefano Verzegnassi

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
import Qt.labs.folderlistmodel 2.1

import "ListItems" as ListItems
import "Upstream"

Page {
    id: rootItem

    property alias folder: folderModel.folder
    property alias rootFolder: folderModel.rootFolder
    property alias nameFilters: folderModel.nameFilters
    property string headerTitle: i18n.tr("Pick a file")

    signal accepted(var path)

    header: PageHeader {
        flickable: view
        title: rootItem.headerTitle
    }

    FolderListModel {
        id: folderModel
        folder: "file:///"
        rootFolder: "file:///"
        showDotAndDotDot: true
        showFiles: true
        showDirsFirst: true
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            id: view
            anchors.fill: parent

            header: ListItems.SectionDivider {
                text: folderModel.folder.toString().replace("file://", "")
            }

            model: folderModel

            delegate: ListItem {
                onClicked: {
                    if (model.fileIsDir)
                        folderModel.folder = model.fileURL
                    else
                        rootItem.accepted(model.fileURL)
                }

                ListItemLayout {
                    anchors.fill: parent
                    title.text: model.fileName

                    Icon {
                        SlotsLayout.position: SlotsLayout.Leading
                        width: units.gu(2); height: width

                        source: "../graphics/folder.svg"
                        name: "folder"
                        visible: model.fileIsDir
                    }
                }
            }
        }
    }
}
