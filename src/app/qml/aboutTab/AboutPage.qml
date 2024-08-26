import QtQuick 2.4
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12
import "../components"

Page {
    id: aboutPage

    header: PageHeader {
        id: header
        title: i18n.tr("About")
        opacity: 1

        extension: Sections {
            id: sections
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            actions: [
                Action {
                    text: i18n.tr("About")
                },
                Action {
                    text: i18n.tr("Credits")
                },
                Action {
                    text: i18n.tr("How It Works")
                }
            ]
            onSelectedIndexChanged: {
                tabView.currentIndex = selectedIndex
            }

        }
    }

    ListModel {
        id: creditsModel
        Component.onCompleted: initialize()

        function initialize() {
            // Resources
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Bugs"), link: "https://github.com/kugiigi/jerk-click/issues" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Contact"), link: "mailto:kugi_eusebio@protonmail.com" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Jerk Installer"), link: "https://github.com/kugiigi/jerk-installer" })
            creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Jerk Packages"), link: "https://github.com/kugiigi/jerk-packages" })

            // Developers
            creditsModel.append({ category: i18n.tr("Developers"), name: "Kugi Eusebio (" + i18n.tr("Main Developer") + ")", link: "https://github.com/kugiigi" })
        }

    }

    VisualItemModel {
        id: tabs

        Item {
            id: aboutItem
            width: tabView.width
            height: tabView.height
            opacity: tabView.currentIndex == 0 ? 1 : 0

            Behavior on opacity {
                NumberAnimation {duration: 200; easing.type: Easing.InOutCubic }
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentHeight: layout.height + units.gu(10)

                Column {
                    id: layout

                    spacing: units.gu(3)
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: units.gu(5)
                    }

                    LomiriShape {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: width
                        width: Math.min(parent.width/2, parent.height/2)
                        source: Image {
                            source: Qt.resolvedUrl("../../jerk-click.svg")
                        }
                        radius: "large"
                    }

                    Column {
                        width: parent.width
                        Label {
                            width: parent.width
                            textSize: Label.XLarge
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: i18n.tr("Ambot Installer")
                        }
                        Label {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("Version %1").arg(appVersion)
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: i18n.tr("Installer of fun, useful but possibly dangerous hacks and mods.")
                    }

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("(C) 2024 Kugi Eusebio")
                        }

                        Label {
                            textSize: Label.Small
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("Released under the terms of the GNU GPL v3")
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        textSize: Label.Small
                        horizontalAlignment: Text.AlignHCenter
                        linkColor: theme.palette.normal.focus
                        text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/kugiigi/jerk-click\">Github</a>")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                }
            }
        }

        Item {
            id: creditsItem
            width: tabView.width
            height: tabView.height
            opacity: tabView.currentIndex == 1 ? 1 : 0

            Behavior on opacity {
                NumberAnimation {duration: 200; easing.type: Easing.InOutCubic }
            }

            ListView {
                id: creditsListView

                model: creditsModel
                anchors.fill: parent
                section.property: "category"
                section.criteria: ViewSection.FullString
                section.delegate: ListItemHeader {
                    title: section
                }

                delegate: ListItem {
                    height: creditsDelegateLayout.height
                    divider.visible: false
                    ListItemLayout {
                        id: creditsDelegateLayout
                        title.text: model.name
                        ProgressionSlot {}
                    }
                    onClicked: Qt.openUrlExternally(model.link)
                }
            }

        }

        Item {
            id: howItem
            width: tabView.width
            height: tabView.height
            opacity: tabView.currentIndex == 2 ? 1 : 0

            Behavior on opacity {
                NumberAnimation {duration: 200; easing.type: Easing.InOutCubic }
            }

            Flickable {
                id: howFlickable
                anchors.fill: parent
                anchors.margins: units.gu(2)
                contentHeight: textColumnLayout.height

                ColumnLayout {
                    id: textColumnLayout

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: i18n.tr("How does the Installer works?\n")
                        textSize: Label.Large
                        font.weight: Font.DemiBold
                    }
                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: [
                            i18n.tr("Ambot Installer uses a script that can modify your system files.")
                            , i18n.tr("When you install a package, it backs up the original files and copy over the modified files from a package you are trying to install.")
                            , i18n.tr("Packages have copies of unmodified files which they are based on and use those to check compatibility with your system.")
                            , i18n.tr("You can't install a package that is not found to be compatible with your system.")
                            , i18n.tr("\n\nWhen you uninstall a package, it checks if it is actually installed to your system and delete the system files that matches the files in the package.")
                            , i18n.tr("New folders created by the package will be retained.")
                            , i18n.tr("Uninstalling a package may take a long time for bigger packages because it reads the files from the archived package file and compare them to the system files.")
                            , i18n.tr("\n\nWhen you reset a component, it simply restores all files the has the filename suffix/extension of this installer's modification (.JERKORIG).")
                            , i18n.tr("It does not delete new files installed by the packages.")
                            , i18n.tr("Because of this, this is a much faster way of removing packages albeit less clean.")
                        ].join(" ")
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: i18n.tr("\n\nWhy are OTA Updates blocked?:\n")
                        textSize: Label.Large
                        font.weight: Font.DemiBold
                    }
                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: [
                            i18n.tr("The Installer updates parts of your system.")
                            , i18n.tr("OTA Updates can be a delta update or a full update.")
                            , i18n.tr("We are avoiding delta updates as it also only updates parts of the system.")
                            , i18n.tr("When a delta update is applied, there is a chance that it changes some files that has conflict to this Installer's changes.")
                            , i18n.tr("A full update on the otherhand is very safe since it puts your system back to a clean slate.")
                            , i18n.tr("OTA updates are blocked via System Settings app to avoid accidental installation of a delta update.")
                            , i18n.tr("\n\nIt is highly recommended to reset all components first before installing an OTA update.")
                        ].join(" ")
                    }
                }
            }
        }
    }

    ListView {
        id: tabView
        anchors {
            top: aboutPage.header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: tabs
        currentIndex: 0

        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: LomiriAnimation.FastDuration

        onCurrentIndexChanged: {
            sections.selectedIndex = currentIndex
        }

    }
}

