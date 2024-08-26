import QtQuick 2.4
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
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
                        text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/kugiigi/jerk-click\">GitLab</a>")
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

