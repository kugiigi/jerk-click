/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015 Stefano Verzegnassi

  Modified for Ambot Installer
  Copyright (C) 2024 Kugi Eusebio

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
import Qt.labs.settings 1.0
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import QtQuick.Layouts 1.15
import QtSensors 5.12
import "components"

MainView {
    // DO NOT MODIFY, this is updated automatically during the build
    readonly property var appVersion: "1.0.6"
    property alias settings: settingsItem
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

    Settings {
        id: settingsItem

        property bool initialDialogShown: false
        property bool extraPowerUnlocked: false
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
                        , Action {
                            id: installExternalAction
                            text: i18n.tr('Install from file')
                            iconName: "document-open"
                            visible: mainView.settings.extraPowerUnlocked && mainPage.header.selectedTabIndex === 0
                            onTriggered: {
                                let _popup = PopupUtils.open(externalInstallDialog, mainView)
                                _popup.accepted.connect(function(_filePath) {
                                    console.log("Selected file!!! " + _filePath)
                                    if (_filePath.toString().trim() !== "") {
                                        externalInstallActionsItem.askToInstallExternalFile(_filePath)
                                    }
                                })
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
            onGranted: {
                if (!mainView.settings.initialDialogShown) {
                    let _popup = PopupUtils.open(initialDialog, mainView)
                    
                    _popup.accepted.connect(function() {
                        mainView.settings.initialDialogShown = true
                    })
                    _popup.getMeOut.connect(function() {
                        Qt.quit();
                    })
                }
            }
        }
    }

    Component {
        id: initialDialog
        Dialog {
            id: initialDialogue

            signal getMeOut
            signal accepted

            title: i18n.tr("Ambot Installer")
            text: [
                i18n.tr("READ BEFORE USE!\n\n")
                ,i18n.tr("This app can and will modify your system files when you install a package.")
                ,i18n.tr("Given the nature of this app's capability, use this app with caution and only when you accept the risk.")
                ,i18n.tr("Although the app and packages were tested to be working, any unexpected issue or bug may render your device unusable.")
                ,i18n.tr("Compatibility check is not foolproof and does not take into account any programmatic incompatibilities/conflicts.")
                ,i18n.tr("It is highly recommended to only use this when you have UBports Installer accessible to you.")
                ,i18n.tr("Don't worry, you can reflash your system without wiping your data like nothing happened :)")
                ,i18n.tr("\n\nBe responsible!\n\n")
                ,i18n.tr("Please remove all changes to your system before reporting an issue to UBports official repositories.")
                ,i18n.tr("You can use the 'Reset All Components' function in this app.")
                ,i18n.tr("After resetting, you may try to replicate the issue and see if it is an actual issue or an issue with the packages installed.")
                ,i18n.tr("\n\nRecommended Package\n\n")
                ,i18n.tr("For devices with rounded corners and/or display cutout, Lomiri Plus Essentials is recommeded.")
                ,i18n.tr("In fact, it's the main reason why this app exists.")
                ,i18n.tr("To easily share the display cutout and rounded corners support until the official one is released.")
            ].join(" ")

            Button {
                text: i18n.tr("I understand the risks")
                color: theme.palette.normal.positive

                onClicked: {
                    initialDialogue.accepted()
                    PopupUtils.close(initialDialogue)
                }
            }

            Button {
                text: i18n.tr("Get me out of here!")
                onClicked: {
                    initialDialogue.getMeOut()
                    PopupUtils.close(initialDialogue)
                }
            }
        }
    }

    Component {
        id: externalInstallDialog

        Dialog {
            id: externalInstallDialogue

            property var cTransfer
            property url filePath

            signal accepted(url filePath)

            onAccepted: PopupUtils.close(externalInstallDialogue)

            title: i18n.tr("Select file from...")

            // Define a ContentStore to store the imported files
            ContentStore {
                id: fileStore
                scope: ContentScope.App
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(externalInstallDialogue)
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(-4)
                }
                height: Math.min(mainView.height - units.gu(10), units.gu(60))

                ContentPeerPicker {
                    showTitle: false
                    contentType: ContentType.All
                    handler: ContentHandler.Source

                    onPeerSelected: {
                        peer.selectionType = ContentTransfer.Single
                        externalInstallDialogue.cTransfer = peer.request(fileStore)  // request transfer and storage in fileStore
                    }

                    onCancelPressed: PopupUtils.close(externalInstallDialogue)
                }

                // Display a waiting screen during transfer
                ContentTransferHint {
                    id: transferHint
                    activeTransfer: externalInstallDialogue.cTransfer
                }
            }

            Connections {
                target: externalInstallDialogue.cTransfer
                onStateChanged: {
                    switch (externalInstallDialogue.cTransfer.state) {
                        case ContentTransfer.Created:
                            console.log("Transfer Created")
                            break;

                        case ContentTransfer.Initiated:
                            console.log("Transfer Initiated")
                            break;

                        case ContentTransfer.InProgress:
                            console.log("Transfer InProgress")
                            break;

                        case ContentTransfer.Downloading:
                            console.log("Transfer Downloading")
                            break;

                        case ContentTransfer.Downloaded:
                            console.log("Transfer Downloaded")
                            break;

                        case ContentTransfer.Charged:
                            console.log("Transfer Charged")
                            for (var i = 0; i < externalInstallDialogue.cTransfer.items.length; i++)
                                externalInstallDialogue.filePath = externalInstallDialogue.cTransfer.items[i].url

                            break;

                        case ContentTransfer.Collected:
                            console.log("Transfer Collected")
                            externalInstallDialogue.cTransfer.finalize()
                            externalInstallDialogue.accepted(externalInstallDialogue.filePath)
                            break;

                        case ContentTransfer.Aborted:
                            console.log("Transfer Aborted")
                            break;

                        case ContentTransfer.Finalized:
                            console.log("Transfer Finalized")
                            break;

                        default:
                            console.log("Transfer Unkonwn State")
                    }
                }
            }

        }
    }

    InstallerActionsItem {
        id: externalInstallActionsItem

        externalFile: true
    }
    
    function openUnlockPowerDialog() {
        let _popup = PopupUtils.open(unlockPowersDialog, mainView)
    }

    Component {
        id: unlockPowersDialog

        Dialog {
            id: unlockPowersDialogue

            property int stage: 0
            property bool unlockedSuccess: false
            property bool unlockedFailed: false

            signal accepted()

            onAccepted: PopupUtils.close(unlockPowersDialogue)

            function randomNumber(min, max) {
                min = Math.ceil(min);
                max = Math.floor(max);
                return Math.floor(Math.random() * (max - min + 1)) + min;
            }

            title: unlockedSuccess ? i18n.tr("Congratulations!") : unlockedFailed ? i18n.tr("You have failed") : ""

            text: {
                if (unlockedSuccess) {
                    return i18n.tr("You have unlocked the power of the Eye. This power can be dangerous. Only use it if you know what you are doing ;;)")
                } else if (unlockedFailed) {
                    return i18n.tr("Your Quantum journey is yet to be completed.")
                } else {
                    switch (stage) {
                        case 0:
                            return i18n.tr("Recall the rule of Quantum Imaging")
                        case 1:
                            return i18n.tr("Recall the rule of Quantum Entanglement")
                        case 2:
                            return i18n.tr("Recall the rule of the Sixth Location")
                        default:
                            return i18n.tr("Recall the rule of Pancit Quantum")
                    }
                }
            }

            Button {
                text: {
                    if (unlockPowersDialogue.unlockedSuccess)
                        return i18n.tr("Let's go!")
                    if (unlockPowersDialogue.unlockedFailed)
                        return i18n.tr("I must return")
                    if (container.eyeSelected)
                        return i18n.tr("Collapse all possibilities")

                    return i18n.tr("I'm not ready")
                }
                color: {
                    if (container.eyeSelected && !unlockPowersDialogue.unlockedFailed) {
                        return theme.palette.normal.positive
                    }

                    return theme.palette.normal.base
                }
                onClicked: {
                    if (container.eyeSelected && !unlockPowersDialogue.unlockedSuccess && !unlockPowersDialogue.unlockedFailed) {
                        if (directionsContainer.selectedIndex === 0) {
                            mainView.settings.extraPowerUnlocked = true
                            unlockPowersDialogue.unlockedSuccess = true
                        } else {
                            unlockPowersDialogue.unlockedFailed = true
                        }
                    } else {
                        PopupUtils.close(unlockPowersDialogue)
                    }
                }
            }

            Item {
                id: container

                property bool volumeUpRecentlyPressed: false
                property bool volumeDownRecentlyPressed: false
                property bool powerButtonAlreadyPressed: false
                readonly property bool screenshotTriggered: volumeUpRecentlyPressed && volumeDownRecentlyPressed
                readonly property bool eyeSelected: planetsContainer.highlightedIndex === 5

                onScreenshotTriggeredChanged: if (screenshotTriggered && quoom.visible) delayScreenshotTimer.restart()
                onPowerButtonAlreadyPressedChanged: if (powerButtonAlreadyPressed) unlockPowersDialogue.stage += 1

                visible: !unlockPowersDialogue.unlockedSuccess && !unlockPowersDialogue.unlockedFailed
                focus: true
                height: !unlockPowersDialogue.unlockedSuccess && !unlockPowersDialogue.unlockedFailed ? units.gu(40) : 0
                Keys.onPressed: {
                    switch (unlockPowersDialogue.stage) {
                        case 0:
                            if (event.key === Qt.Key_VolumeDown) {
                                container.volumeDownRecentlyPressed = true
                                volumeDownTimeoutTimer.restart()
                            }
                            if (event.key === Qt.Key_VolumeUp) {
                                container.volumeUpRecentlyPressed = true
                                volumeUpTimeoutTimer.restart()
                            }
                        break
                        case 1:
                        case 2:
                            if (event.key === Qt.Key_PowerOff) {
                                planetSelectDelayTimer.restart()
                            }
                        break
                            
                    }
                }
                Rectangle {
                    id: blackoutRec
                    opacity: 0
                    visible: opacity > 0
                    color: "black"
                    anchors.fill: parent
                    anchors.margins: units.gu(-2)
                    anchors.topMargin: 0
                    radius: units.gu(2)
                    z: 9999
                    Behavior on opacity { LomiriNumberAnimation { duration: LomiriAnimation.BriskDuration } }
                    onOpacityChanged: {
                        if (opacity === 1) {
                            container.powerButtonAlreadyPressed = true
                            planetsContainer.randomHighlight()
                        }
                    }

                    function show() {
                        opacity = 1
                    }
                    function hide() {
                        opacity = 0
                    }
                }
                Timer {
                    id: volumeDownTimeoutTimer
                    interval: 200
                    onTriggered: container.volumeDownRecentlyPressed = false
                }
                Timer {
                    id: volumeUpTimeoutTimer
                    interval: 200
                    onTriggered: container.volumeUpRecentlyPressed = false
                }
                Timer {
                    id: delayScreenshotTimer
                    interval: 1000
                    onTriggered: unlockPowersDialogue.stage += 1
                }
                Timer {
                    id: planetSelectDelayTimer
                    interval: 500
                    onTriggered: {
                        container.powerButtonAlreadyPressed = true
                        planetsContainer.randomHighlight()
                    }
                }

                function restartTimer() {
                    refreshTimer.interval = unlockPowersDialogue.randomNumber(1000, 10000)
                    refreshTimer.restart()
                }

                function refreshQuantumMoon() {
                    const _visibleInt = unlockPowersDialogue.randomNumber(0, 60)
                    const _shouldBeVisible = _visibleInt <= 50; // Randomize visibility with 1 to 6 chance of disappearing

                    if (_shouldBeVisible) {
                        quoom.x = unlockPowersDialogue.randomNumber(0, container.width - quoom.width)
                        quoom.y = unlockPowersDialogue.randomNumber(0, container.height - quoom.height)
                    }

                    quoom.shouldShow = _shouldBeVisible

                    restartTimer()
                }

                LightSensor {
                    id: lightSensor
                    active: unlockPowersDialogue.stage >= 1
                    dataRate: 20
                    onReadingChanged: {
                        if (reading.illuminance <= 1) {
                            blackoutRec.show()
                        } else {
                            blackoutRec.hide()
                        }
                    }
                }
                Compass {
                    id: compassSensor

                    property bool isWorking: false

                    active: unlockPowersDialogue.stage >= 2
                    dataRate: 20

                    // Detect if the sensor is actually working
                    onReadingChanged: if (!isWorking && reading.azimuth > 0) isWorking = true
                }

                Icon {
                    id: quoom
                    
                    property bool shouldShow: false

                    visible: unlockPowersDialogue.stage === 0 && shouldShow
                    width: units.gu(10)
                    height: width
                    source: "graphics/quantum_moon.svg"
                    color: theme.palette.normal.backgroundText
                    keyColor: "#000000"
                    Component.onCompleted: container.refreshQuantumMoon()
                }

                Timer {
                    id: refreshTimer
                    onTriggered: container.refreshQuantumMoon()
                }

                ColumnLayout {
                    anchors.fill: parent

                    Item {
                        id: planetsContainer

                        property int highlightedIndex: unlockPowersDialogue.randomNumber(0, 4)

                        visible: unlockPowersDialogue.stage >= 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        function randomHighlight() {
                            const _selectEye = unlockPowersDialogue.randomNumber(0, 3)
                            if (_selectEye <= 2 || highlightedIndex === 5) {
                                let _newIndex = highlightedIndex
                                while (_newIndex === highlightedIndex) {
                                    _newIndex = unlockPowersDialogue.randomNumber(0, 5)
                                }
                                highlightedIndex = _newIndex
                            } else {
                                highlightedIndex = 5
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            
                            Repeater {
                                model: [
                                    "hourglass_twins.svg"
                                    , "timber_hearth.svg"
                                    , "brittle_hollow.svg"
                                    , "giants_deep.svg"
                                    , "dark_bramble.svg"
                                    , "nomai_eye.svg"
                                ]
                                
                                delegate: Icon {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: width
                                    source: "graphics/" + modelData
                                    color: planetsContainer.highlightedIndex === index ? theme.palette.normal.activity //"#4c5195"
                                                    : theme.palette.normal.backgroundText
                                    keyColor: "#ffffff"

                                    Rectangle {
                                        visible: planetsContainer.highlightedIndex === index
                                        anchors.fill: parent
                                        anchors.margins: units.gu(-0.5)
                                        radius: width / 2
                                        color: "transparent"
                                        border {
                                            width: units.dp(1)
                                            color: theme.palette.normal.activity
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                     Item {
                        id: directionsContainer

                        Layout.fillHeight: true
                        Layout.preferredWidth: Math.min(height, parent.width)
                        Layout.alignment: Qt.AlignCenter

                        visible: unlockPowersDialogue.stage === 2

                        readonly property real radius: width / 2
                        property int selectedIndex: unlockPowersDialogue.randomNumber(0, 7)

                        Icon {
                            anchors.centerIn: parent
                            height: Math.min(parent.width, parent.height)
                            width: height
                            source: "graphics/quantum_moon.svg"
                            color: theme.palette.normal.backgroundText
                            keyColor: "#000000"
                        }

                        Repeater {
                            id: directionsRepeater

                            model: [
                                {text: "N",  angle: 0},
                                {text: "NE", angle: 45},
                                {text: "E",  angle: 90},
                                {text: "SE", angle: 135},
                                {text: "S",  angle: 180},
                                {text: "SW", angle: 225},
                                {text: "W",  angle: 270},
                                {text: "NW", angle: 315}
                            ]

                            delegate: AbstractButton {
                                width: units.gu(3)
                                height: width
                                x: directionsContainer.width/2  - width/2  + directionsContainer.radius * Math.sin(modelData.angle * Math.PI / 180)
                                y: directionsContainer.height/2 - height/2 - directionsContainer.radius * Math.cos(modelData.angle * Math.PI / 180)
                                Connections {
                                    target: compassSensor
                                    onReadingChanged: {
                                        // Only force selection if the sensor actually works. Otherwise, let the user click on a direction
                                        if (target.isWorking) {
                                            const _currentReading = target.reading.azimuth
                                            if ((modelData.angle === 0 && (_currentReading > 360 - 22.5 || _currentReading <= modelData.angle + 22.5))
                                                    || (modelData.angle !== 0 && _currentReading > modelData.angle - 22.5 && _currentReading <= modelData.angle + 22.5)
                                                    ) {
                                                directionsContainer.selectedIndex = index
                                            }
                                        }
                                    }
                                }

                                onClicked: directionsContainer.selectedIndex = index

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: directionsContainer.selectedIndex === index ? theme.palette.normal.activity : theme.palette.normal.foreground
                                }

                                Label {
                                    id: directionLabel
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    color: directionsContainer.selectedIndex === index ? theme.palette.normal.activityText : theme.palette.normal.foregroundText
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    readonly property var componentList: [
        {
            "component_id": "all"
            , "name": "All Components"
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

