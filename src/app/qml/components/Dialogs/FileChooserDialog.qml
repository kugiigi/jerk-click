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
import Qt.labs.folderlistmodel 2.1
import QtQuick.Layouts 1.1

import "../ListItems" as ListItem
import "../Upstream"

Page {
    id: rootItem

    property alias folder: folderModel.folder
    property alias rootFolder: folderModel.rootFolder
    property alias nameFilters: folderModel.nameFilters
    property alias multipleSelection: view.multipleSelection
    // Supported modes: filesOnly, dirsOnly, filesAndDir
    property string mode: "filesOnly"

    signal rejected
    signal accepted(var pathsList)

    title: " "

    header: PageHeader {
        id: fileChooserHeader
        leadingActionBar.actions: [
            Action {
                iconName: "close"
                text: i18n.tr("Cancel")
                onTriggered: {
                    rootItem.rejected();
                    pageStack.pop();
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                enabled: rootItem.multipleSelection
                visible: enabled

                text: {
                    if(view.selectedItems.count === view.count) {
                        return i18n.tr("Select None")
                    } else {
                        return i18n.tr("Select All")
                    }
                }

                iconSource: {
                    var isDir;
                    var c=0;
                    for (var ii=0; ii<view.count; ii++) {
                        isDir = folderModel.get(ii, "fileIsDir");

                        if (rootItem.mode == "filesOnly" && !isDir) {
                            c++;
                        } else if (rootItem.mode == "dirsOnly" && isDir) {
                            c++
                        } else if (rootItem.mode == "filesAndDir") {
                            c++
                        }
                    }

                    if(view.selectedItems.count === c) {
                        return Qt.resolvedUrl("../../graphics/select-none.svg")
                    } else {
                        return Qt.resolvedUrl("../../graphics/select.svg")
                    }
                }

                onTriggered: {
                    var isDir;
                    var c=0;
                    for (var ii=0; ii<view.count; ii++) {
                        isDir = folderModel.get(ii, "fileIsDir");

                        if (rootItem.mode == "filesOnly" && !isDir) {
                            c++;
                        } else if (rootItem.mode == "dirsOnly" && isDir) {
                            c++
                        } else if (rootItem.mode == "filesAndDir") {
                            c++
                        }
                    }

                    if(view.selectedItems.count === c) {
                        view.clearSelection()
                    } else {
                        // We can not use view.selectAll() since we may want to
                        // select folders but files, or vice versa.
                        var i=0;

                        if (rootItem.mode === "filesOnly") {
                            while (folderModel.get(i, "fileIsDir")) {
                                i++;
                            }

                            view.model.items.addGroups(i, view.count - i, ["selected"] )
                            return;
                        } else if (rootItem.mode === "dirsOnly") {
                            while (folderModel.get(i, "fileIsDir")) {
                                i++;
                            }

                            view.model.items.addGroups(0, i, ["selected"] )
                            return;
                        } else {
                            // Else rootItem.mode === "filesAndDirs"
                            view.selectAll()
                        }
                    }
                }
            },

            Action {
                text: i18n.tr("Pick")
                enabled: view.selectedItems.count > 0
                iconName: "ok"
                onTriggered: {
                    if (!enabled)
                        return;

                    var pathsList = [];
                    for (var i=0; i<view.selectedItems.count; i++) {
                        pathsList.push(view.selectedItems.get(i).model.fileURL)
                    }

                    rootItem.accepted(pathsList);
                    pageStack.pop();
                }
            }
        ]
    }
    onActiveChanged: view.anchors.fill = view.parent

    FolderListModel {
        id: folderModel

        folder: "file:///"
        rootFolder: "file:///"
        showFiles: rootItem.mode != "dirsOnly"
        showDirsFirst: true

        onFolderChanged: view.clearSelection()
    }

    MultipleSelectionListView {
        id: view

        multipleSelection: false
        currentIndex: -1
        listModel: folderModel
        anchors.top: fileChooserHeader.bottom

        header: Column {
            width: parent.width


            ListItem.SectionDivider {
                text: folderModel.folder.toString().replace("file://", "")
            }

            ListItem.Base {
                enabled: folderModel.folder != folderModel.rootFolder
                visible: enabled

                onClicked: {
                    if (enabled)
                    folderModel.folder = folderModel.parentFolder
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: units.gu(2)

                    Icon {
                        width: units.gu(2); height: width
                        source: Qt.resolvedUrl("../../graphics/back.svg")
                        color: theme.palette.normal.negative
                    }

                    Label {
                        text: i18n.tr("Back to parent folder")
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.fillWidth: true
                    }
                }
            }
        }

        listDelegate: ListItem.Base {
            id: delegate
            property bool selected: view.isSelected(delegate)

            height: units.gu(8)
            width: parent.width

            onClicked: {
                if (model.fileIsDir)
                    folderModel.folder = model.fileURL;
            }

            RowLayout {
                anchors.fill: parent
                spacing: units.gu(2)

                /*
                  'selectMode' property of ListItem works only on all the items.
                   We need to filter out which items will be selectable and
                   which not, so we have to go for our own implementation.
                */
                CheckBox {
                    id: selector

                    __mouseArea.enabled: false
                    checked: delegate.selected
                    enabled: visible
                    visible: {
                        if (model.fileIsDir && rootItem.mode !== "filesOnly") {
                            return true;
                        } else {
                            if (!model.fileIsDir && rootItem.mode !== "dirsOnly")
                                return true;

                            return false;
                        }
                    }

                    AbstractButton {
                        anchors.fill: parent
                        onClicked: {
                            if (!delegate.selected)
                                view.selectItem(delegate);
                            else
                                view.deselectItem(delegate);
                        }
                    }
                }

                Icon {
                    width: units.gu(2); height: width

                    name: "folder"
                    source: "../../graphics/folder.svg"
                    visible: model.fileIsDir
                }

                Label {
                    text: model.fileName
                    Layout.fillWidth: true
                }
            }
        }
    }
}
