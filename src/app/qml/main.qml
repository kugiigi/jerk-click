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
import com.ubuntu.PamAuthentication 0.1
import QtQml.Models 2.1

MainView {
    // DO NOT MODIFY, this is updated automatically during the build
    readonly property var appVersion: "1.0.0"
    property alias overlayContainer: overlayContainer

    id: mainView
    objectName: "mainView"
    applicationName: "jerk-click.kugiigi"

    width: units.gu(100)
    height: units.gu(76)

    Component.onCompleted: {
        window.minimumWidth = units.gu(100)
        window.minimumHeight = units.gu(60)
    }

    AdaptivePageLayout {
        id: pageStack
        anchors.fill: parent

        function push(page, properties) {
            return pageStack.addPageToNextColumn(primaryPage, page, properties)
        }

        primaryPage: Page {
            id: mainPage
            clip: pageStack.columns > 1

            // TODO: Revert to PageHeader.sections as soon as Lomiri UITK component allows to scroll its labels.
            header: PageHeader {
                id: mainPageHeader
                property int selectedTabIndex: 0

                onSelectedTabIndexChanged: {
                    // Current section has changed, if there was an opened page
                    // in the second column, it is not anymore related to the
                    // new current section.
                    mainPage.pageStack.removePages(mainPage)
                }

                leadingActionBar.actions: [
                    Action {
                        text: i18n.tr("Installer")
                        onTriggered: mainPage.header.selectedTabIndex = 0
                        iconName: mainPage.header.selectedTabIndex == 0 ? "tick" : "package-x-generic-symbolic"
                    },

                    Action {
                        text: i18n.tr("Actions")
                        onTriggered: mainPage.header.selectedTabIndex = 1
                        iconName: mainPage.header.selectedTabIndex == 1 ? "tick" : "other-actions"
                    },

                    Action {
                        text: i18n.tr("Settings")
                        onTriggered: mainPage.header.selectedTabIndex = 2
                        iconName: mainPage.header.selectedTabIndex == 2 ? "tick" : "settings"
                    }
                ]

                trailingActionBar {
                    actions: [
                        Action {
                            id: startAction
                            text: i18n.tr('About')
                            iconName: "info"
                            onTriggered: {
                                mainPage.pageStack.push(Qt.resolvedUrl("aboutTab/AboutPage.qml"))
                            }
                        }
                    ]
                }

                contents: ListItemLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: units.gu(0.25)
                    title.text: i18n.tr("Ambot Installer") + " (v%1)".arg(appVersion)
                    subtitle.text: mainPageHeader.leadingActionBar.actions[mainPageHeader.selectedTabIndex].text
                }

                title: i18n.tr("Ambot Installer")
            }

            ListView {
                id: view
                anchors {
                    top: mainPage.header.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                clip: true
                orientation: ListView.Horizontal
                interactive: false
                snapMode: ListView.SnapOneItem
                highlightMoveDuration: 0
                currentIndex: mainPage.header.selectedTabIndex

                model: ObjectModel {
                    Loader {
                        width: view.width
                        height: view.height
                        asynchronous: true
                        source: Qt.resolvedUrl("installerTab/InstallerTab.qml")
                    }
                    Loader {
                        width: view.width
                        height: view.height
                        asynchronous: true
                        source: Qt.resolvedUrl("actionsTab/ActionsTab.qml")
                    }
                    Loader {
                        width: view.width
                        height: view.height
                        asynchronous: true
                        source: Qt.resolvedUrl("settingsTab/SettingsTab.qml")
                    }
                }
            }
        }
    }

    Rectangle {
        id: overlayContainer

        property string loadingText

        anchors.fill: parent
        color: "#E3000000"
        visible: opacity > 0
        opacity: 0
        Behavior on opacity { LomiriNumberAnimation { duration: LomiriAnimation.BriskDuration } }

        function showAsModal(_text = "") {
            loadingText = _text
            mouseEater.enabled = true
            activity.visible = true
            show()
        }

        function show() {
            opacity = 1
        }

        function hide() {
            opacity = 0
        }

        onVisibleChanged: {
            if (!visible) {
                mouseEater.enabled = false
                activity.visible = false
                loadingText = ""
            }
        }

        ActivityIndicator {
            id: activity
            visible: false
            anchors.centerIn: parent
            running: visible
        }

        Label {
            text: overlayContainer.loadingText
            color: "white"
            textSize: Label.Large
            horizontalAlignment: Text.AlignHCenter
            anchors {
                top: activity.bottom
                topMargin: units.gu(2)
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            wrapMode: Text.WordWrap
        }

        MouseArea {
            id: mouseEater
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onWheel: wheel.accepted = true;
            enabled: false
            visible: enabled
        }
    }

    property alias pam: pamLoader.item
    Loader {
        id: pamLoader
        // A bit nonsense, but we're not using pam for security
        asynchronous: true
        sourceComponent: AuthenticationService {
            id: pam
            serviceName: "jerk-click"
            onDenied: Qt.quit();
        }
    }

    readonly property var componentList: [
        {
            "component_id": "all"
            , "name": "All Components"
            , "hasRestart": false
        }
        , {
            "component_id": "bluetooth_conf"
            , "name": "Bluetooth Config"
            , "hasRestart": false
        }
        , {
            "component_id": "lomiri"
            , "name": "Lomiri"
            , "hasRestart": true
        }
        , {
            "component_id": "maliit-keyboard"
            , "name": "Lomiri Keyboard"
            , "hasRestart": true
        }
        , {
            "component_id": "maliit-keyboard-layouts"
            , "name": "Lomiri Keyboard Layouts"
            , "hasRestart": true
        }
        , {
            "component_id": "system-settings"
            , "name": "System Settings app"
            , "hasRestart": true
        }
        , {
            "component_id": "uitk"
            , "name": "Lomiri Toolkit"
            , "hasRestart": false
        }
        , {
            "component_id": "webcontainer"
            , "name": "Web App Container"
            , "hasRestart": false
        }
    ]
}

