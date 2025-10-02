import QtQuick 2.4
import Lomiri.Components 1.3
 import Lomiri.Components.Styles 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.12

import "../components"
import "../components/ListItems" as ListItems
import "../js/shell.js" as Shell

Page {
    id: rootItem

    readonly property var packageData: packageList.find(item => item.package_id == package_id)
    readonly property var componentData: mainView.componentList.find(item => item.component_id == component_id)
    readonly property var screenshotsModel: packageData ? packageData.screenshots : []
    readonly property string fileName: packageData ? packageData.file_name : ""
    readonly property string description: packageData ? packageData.description : i18n.tr("No description")
    readonly property string changelog: packageData ? packageData.changelog : ""
    readonly property string developer: packageData ? packageData.developer : i18n.tr("Unkown Developer")
    readonly property url devUrl: packageData ? packageData.devUrl : i18n.tr("https://github.com/kugiigi/jerk-packages")
    readonly property url sourceUrl: packageData ? packageData.sourceUrl : i18n.tr("https://github.com/kugiigi/jerk-packages")
    readonly property string componentName: componentData ? componentData.name : i18n.tr("Unknown Component")
    readonly property bool hasRestart: componentData ? componentData.hasRestart : false
    readonly property bool hasOldVersion: packageData && packageData.old_version

    property string package_id
    property string component_id
    property string pageTitle

    header: PageHeader {
        title: rootItem.pageTitle
        flickable: view
    }

    InstallerActionsItem {
        id: actionsItem

        package_id: rootItem.package_id
        packageName: rootItem.pageTitle
        component_id: rootItem.component_id
        componentName: rootItem.componentName
        fileName: rootItem.fileName
        hasRestart: rootItem.hasRestart
    }

    QtObject {
        id: internal

        readonly property real maximumItemWidth: units.gu(80)
    }

    Component.onCompleted: actionsItem.checkComponentIfClean()

    ScrollView {
        id: scrollView

        anchors.fill: parent

        Flickable {
            id: view
            anchors.fill: parent
            contentHeight: columnLayout.height
            topMargin: units.gu(2)
            bottomMargin: units.gu(4)

            ColumnLayout {
                id: columnLayout

                spacing: units.gu(1)
                anchors {
                    left: parent.left
                    right: parent.right
                }

                ScreenshotsList {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.gu(32)
                    model: rootItem.screenshotsModel
                    path: rootItem.package_id
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    wrapMode: Text.WordWrap
                    text: i18n.tr("Modifications found in %1. This package or another one might be already installed.").arg(rootItem.componentName)
                    font.italic: true
                    color: theme.palette.normal.negative
                    visible: actionsItem.confirmedComponentIsDirty
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: {
                        if (rootItem.hasOldVersion) {
                            return actionsItem.confirmedComponentIsDirty ? i18n.tr("Install Anyway (Latest version)") : i18n.tr("Install (Latest version)")
                        } else {
                            return actionsItem.confirmedComponentIsDirty ? i18n.tr("Install Anyway") : i18n.tr("Install")
                        }
                    }
                    color: actionsItem.confirmedComponentIsDirty ? theme.palette.normal.base : theme.palette.normal.positive
                    visible: actionsItem.componentWasChecked
                    onClicked: actionsItem.askToInstall()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: actionsItem.confirmedComponentIsDirty ? i18n.tr("Install Anyway (Previous version)") : i18n.tr("Install (Previous version)")
                    color: theme.palette.normal.base
                    visible: actionsItem.componentWasChecked && rootItem.hasOldVersion
                    onClicked: actionsItem.askToInstall(true)
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: i18n.tr("Try to Uninstall")
                    color: theme.palette.normal.base
                    visible: actionsItem.confirmedComponentIsDirty
                    onClicked: actionsItem.askToUninstall()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: i18n.tr("Reset %1").arg(rootItem.componentName)
                    color: theme.palette.normal.negative
                    visible: actionsItem.confirmedComponentIsDirty
                    onClicked: actionsItem.askToReset()
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.italic: true
                    visible: restartButton.visible
                    text: i18n.tr("Restart the affected component for the installation/uninstallation to take effect")
                }

                Button {
                    id: restartButton
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: i18n.tr("Restart %1").arg(rootItem.componentName)
                    visible: rootItem.hasRestart
                    onClicked: actionsItem.askToRestart()
                }

                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: units.gu(2)
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    text: rootItem.pageTitle
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    textSize: Label.Large
                }

                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: units.gu(1)
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: rootItem.description
                    wrapMode: Text.WordWrap
                }

                ListItems.Link {
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: i18n.tr("Developer")
                    summary.text: rootItem.developer
                    summary.maximumLineCount: Number.MAX_VALUE
                    url: rootItem.devUrl
                    divider.visible: false
                }

                ListItems.Link {
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    text: i18n.tr("Source Code")
                    summary.text: rootItem.sourceUrl
                    summary.maximumLineCount: Number.MAX_VALUE
                    url: rootItem.sourceUrl
                    divider.visible: false
                }

                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: units.gu(2)
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    text: i18n.tr("Changelog")
                    wrapMode: Text.WordWrap
                    textSize: Label.Large
                    visible: changelogLabel.visible
                }

                Label {
                    id: changelogLabel

                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                    Layout.rightMargin: units.gu(2)
                    Layout.maximumWidth: internal.maximumItemWidth
                    Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                    visible: rootItem.changelog.trim() !== ""
                    text: rootItem.changelog
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Hardcoded data
    readonly property var packageList: [
        {
            "package_id": "malakiboard"
            , "file_name": "Malakiboard"
            , "old_version": true
            , "description": "Malakiboard is a collection of hacks, modifications, and mods for the Lomiri keyboard used in Ubuntu Touch. \
It is Kugi's playground for fixes, changes and new features that may or may never land on the upstream Lomiri keyboard. \
\n\nAdditional settings can be accessed by long pressing the language switcher/emoji key and selecting 'Malakiboard Settings' at the bottom.\
\n\n \
New Features: \n\
- Custom height for portrait and landscape orientation\n \
- Custom word ribbon height and keyboard margins\n \
- Theming support: Create your own theme! Follow system theme and a lot more customizations\n \
- One-handed and floating mode\n \
- Number row, hide domain (.com, .org) key, and a lot more options\n \
- Tobiyo's Flick keyboard\n \
- Quick Actions: Swipe up from the left or right sides to access actions that you can quickly trigger\n \
- Swipie-To-Delete: Swipe from the Backspace key to immediately select text and delete them upon lifting your finger"
            , "screenshots": [ "1.png", "2.png", "3.png", "4.png", "5.png", "6.png" ]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Keyboard/Malakiboard"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.7\n\
- Compatibility with recent Focal OTAs\n\
- Option to replace the extended keys of the Period key with domain keys in EN layout\n\
- Exit cursor swipe mode when entering Notebook\n\
- Option to hide Language key\n\
- Replaced Checkbox in settings with one from Lomiri Plus and customized a bit\n\
- New Language Switcher action for the Shortcuts Bar\n\
- Interchange undo and redo in word ribbon when in cursor swipe mode\n\
- Implemented custom clipboard in the Notebook feature\n\n\n\
v1.6\n\
- Notebook: Feature for saving texts that are available for pasting whenever you need them\n\
- Custom Themes: Allow adding and creating unlimited number of custom themes\n\
- Shortcuts Bar: Display easily accessible actions in the word ribbon\n\
- Added option to show text preview at the top of the keyboard when in floating mode\n\
- Added option to access Emoji keyboard from the Shortcuts Bar and display it as a layout instead of a separate language\n\
- Fixed non-interactive area below the keyboard when in floating mode\n\
- Updated Settings Slider from Lomiri Plus \n\n\n\
v1.5 \n\
- Commit text when using redo and undo actions \n\
- Added option for custom bottom and side margins \n\
- Fixed some remaining Ubuntu imports \n\
- Apply margins to cursor mover mode \n\
- Implemented swipe to delete in the backspace key. Swipe from the backspace key to immediately select text and delete them upon release. \n\
- Changed icon from cancel to close in quick actions page"
        }
        , {
            "package_id": "malakiboard_layouts"
            , "file_name": "MalakiboardLayouts"
            , "old_version": true
            , "description": "This is a companion package for Malakiboard which includes changes specific to languages/layouts. Install this if you installed Malakiboard to get the full functionalities and features."
            , "screenshots": []
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Keyboard/MalakiboardLayouts"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "bredr_fast"
            , "file_name": "Bluetooth_BRDER_FAST"
            , "old_version": false
            , "description": "This changes controller mode from 'auto' to 'bredr' and enables 'FastConnectable'. This may fix some Bluetooth issues but there's no guarantee and battery drain may be higher. Feel free to try."
            , "screenshots": []
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Bluetooth_Conf/BREDR_FAST"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "dialerapp_redesigned"
            , "file_name": "DialerAppRedesigned"
            , "old_version": false
            , "description": "This a redesign of the dialer app that is already merged but will probably be only released in Noble."
            , "screenshots": ["1.png", "2.png", "3.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/DialerApp/Redesign"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "settings_show_launcher"
            , "file_name": "Settings_ShowLauncher"
            , "old_version": false
            , "description": "This makes the 'Desktop & Launhcer' settings page to be always shown instead of being only shown in large screens."
            , "screenshots": ["1.png", "2.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/System_Settings/ShowLauncher"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "sapot_container"
            , "file_name": "SapotContainer"
            , "old_version": true
            , "description": "Sapot Container modifies the standard web app container to make it look and work similar to the Sapot Browser. This brings many features available in Sapot Browser.\n\n \
Notable Features:\n \
- Bottom horizontal swipe gesture for navigating back and forward in web pages\n \
- Force desktop or mobile version of sites\n \
- Open links in an overlay or externally\n \
- Different types of context menu\n \
- Scroll positioner floating button\n \
- Auto-hide of title bar\n \
- Quick Actions and Custom URL Actions: Swipe up from the left or right side of the bottom edge to access actions that can be triggered upon lifting of your finger. \
You can also add custom URLs as Quick Actions to help you quickly accessing pages"
            , "screenshots": ["1.png", "2.png", "3.png", "4.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/WebContainer/SapotContainer"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.3\n\
- Pull up webview when onscreen keyboard is displayed\n\
- Option to put the scroll positioner to a different position when in wide layout\n\
- Changed the behavior of the Incognito overlay setting. It will now only affect external links when opened on an overlay.\n\
  For internal links, a new option to explicitly open them in invognito overlay has been added\n\
- Title bar now hides immediately upon start up when the webapp is set to always hide it\n\
- Implemented work around to hide tooltip when it gets stuck being shown\n\
- Fixed context menu position when opened with mouse in wide layout\n\n\n\
v1.2\n\
- Implemented Reader mode\n\
- Added option for a floating scroll button\n\
- UI improvements in the Settings page\n\
- Fixed forcing mobile site on big screens\n\
- Fixed Google and Baidu when searching\n\
- Allow closing overlay pages with mouse back button\n\n\n\
v1.1\n \
- Fixed error in right clicking empty space\n \
- Fixed search text from overlays\n \
- External links will always open in incognito mode in the overlay\n \
- Context menu item to open link externally\n \
- Fixed loading bar in overlay not shown properly\n \
- Implemented Share functionalities\n \
- New quick actions for sharing and copying current link\n \
- New quick action for opening a search page in an overlay\n \
- Implemented requesting desktop or mobile version of sites\n \
- Added search engine settings\n \
- Fixed context menu in wide layout"
        }
        , {
            "package_id": "marikit"
            , "file_name": "MariKit"
            , "old_version": false
            , "description": "MariKit changes components and adds features to the Lomiri toolkit which is used by most Ubuntu Touch apps especially the core apps. \
New features may not work properly, or at all, on some apps since it depends on how the app uses the modified Toolkit components.\n\n\
Notable features:\n \
- Adds horizontal swipe gesture at the bottom edge of pages to access the corresponding actions in the header. \
Swiping to the left will trigger the right header action or open a menu if there are many.\
Swiping to the right will trigger the left header action which is usally the back button\n \
- Adds the same gesture as above but in page headers"
            , "screenshots": ["1.png", "2.png", "3.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/UITK/MariKit"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.2\n\
- Fixed anchor keyboard in dialogs in apps with Qt::AA_EnableHighDpiScaling such as Morph\n\
- Force bottom gesture in apps where Header is used but not Page (Affects apps like TELEports)\n\
- New QML property to force disable bottom gestures in `Page` components\n\n\n\
v1.1 \n \
- Settings implementation for gesture enablement and visual hint\n \
- Implemented swipe gesture on the header\n \
- Implemented back gesture animation in pages"
        }
        , {
            "package_id": "lomiri_plus_essentials"
            , "file_name": "LomiriPlus_Essentials"
            , "old_version": true
            , "description": "** Recommended for devices with rounded corners and/or display cutout/notch **\n\n\
This is a minimal version of Lomiri Plus that only includes fixes, changes and new features that are 'essential' such as Notch and Rounded Corners support. \
\n\nAdditional settings can be accessed from the System indicator at the rightmost of Indicators\n\n \
Notable features:\n \
- Device configuration for setting notch and rounded corner dimensions to adjust the UI accordingly \n \
- Option to enable Side-stage. Splitscreen-like feature that is enabled in landscape orientation. Apps can be dragged between stages with 3-finger drag. 3-finger tap will show/hide the Side-stage\n \
- Floating button that appears when rotating the device while screen orientaion is locked. Pressing this button will rotate the screen based on the physical orientation of the device.\n \
- Various indicator settings/options such as always hiding/showing icons in the top bar"
            , "screenshots": ["1.png", "2.png", "3.png", "4.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Lomiri/Lomiri_Plus_Essentials"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.1\n\
- Work around to fix Never games and other games that has incorrect orientation\n\n\n\
v1.0 \n\
- Initial release"
        }
        , {
            "package_id": "lomiri_plus"
            , "file_name": "LomiriPlus"
            , "old_version": true
            , "description": "** Not recommended for most users as this changes a lot of things which makes it more prone from unexpected results such as higher battery drain and worse system performance. \
Install at your own risk! **\n\n\
Lomiri Plus is Kugi's playground for all his experiments in Lomiri. It includes fixes, changes, new features and random things that may or may never land in upstream Lomiri. \
This is a big package that changes many things in Lomiri. This is not professionally made and may or may not include some surprises. \
\n\nLomiri Plus settings can be accessed from the System indicator at the rightmost of Indicators or by swiping up from the bottom of the lockscreen, if enabled.\n\n \
\
Notable features:\n \
- Device configuration for setting notch and rounded corner dimensions to adjust the UI accordingly \n \
- Option to enable Side-stage. Splitscreen-like feature that is enabled in landscape orientation. Apps can be dragged between stages with 3-finger drag. 3-finger tap will show/hide the Side-stage\n \
- Floating button that appears when rotating the device while screen orientaion is locked. Pressing this button will rotate the screen based on the physical orientation of the device.\n \
- Various indicator settings/options such as always hiding/showing icons in the top bar\n \
- Lots of customization settings for different parts of the UI such as the Launcher, Drawer, and Top Bar.\n \
- Quick Actions: Swipe from the bottom-most side of the left or right edge to access different type of actions which can be triggered upon lifting your finger\n \
- Quick Toggles: Adds toggles at the bottom part of the Indicator panels which can be used to quickly toggle settings such as WiFi and Bluetooth\n \
- Dynamic Cove: Adds many functions in the Infographics circle in the lockscreen including media controls and timer\n \
- App Grids: Adds customizable pages in the App Drawer\n \
- Outer Wilds themes ::)"
            , "screenshots": ["1.png", "2.png", "3.png", "4.png", "5.png", "6.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Lomiri/Lomiri_Plus_Essentials"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v2.3\n\
New Features:\n\
- [Abot Kamay] New option to change the location and height of the swipe area for Abot Kamay\n\
- [App Drawer] Option to extend over the Top Bar or not\n\
- [App Grids] Added option for indicator size and disabling expansion when hovering with mouse\n\
- [Convergence] Option to set the brightness to low when an external display is connected and in virtual touchpad mode\n\
- [Convergence] Option to make cursor bigger on external displays\n\
- [Detox Mode] Display a fun page at fixed or random interval when using apps that you selected to be part of your digital detox ::)\n\
- [Dynamic Cove] Option to hide infographics circles when in CD Player\n\
- [Dynamic Cove/Infographics] Option to display on the desktop when device is unlocked\n\
- [Extras] Option to show BSOD with delay\n\
- [Fingerprint] Option to require a swipe before fully unlocking and hiding the lockscreen\n\
- [Fully Charged Alarm] Added option in dialog to notify full charged silently\n\
- [Fully Charged Alarm] Option to show charging time\n\
- [Indicator Panels] Option to expand header of the Notifications panel only when there are notifications when opened from a bottom gesture\n\
- [Indicator Panels] Option to use indicator selector when opening the Indicator panels from a bottom gesture\n\
- [Outer Wilds] Option to display the Solar System on the desktop\n\
- [Physical Buttons] Option to disable volume buttons when Camera app is the current app\n\
- [Punchhole Battery Indicator] Support for middle position and changed < 50% to yellow instead of orange\n\
- [Quick Actions] Option to use physical size of items or not when swiping\n\
- [Quick Actions] Option to select items with or without offset below the item\n\
- [Quick Actions] Added option to display items where you start the swipe instead of always being fixed at the top of the swipe area\n\
- [Quick Actions] Option to make the swipe gesture accessible even while the OSK is displayed\n\
- [Quick Actions] Option to use an icon for certain action types\n\
- [Quick Actions] Option to use custom title\n\
- [Quick Toggles] Option to only show in Notification/Messages indicator panel\n\
- [Quick Toggles] Added Auto-brightness toggle in the Brightness slider to switch betweeen disabled, system and custom auto-brightness\n\
- [Screenshot] Add option to disable sound when taking a screenshot\n\
- [Top Bar] Option to disable balanced spacing for the icons on the left and right of the middle notch\n\
- [Window Decoration] Introduce Clean mode in Windowed mode which hides the title bar of windows\n\n\n\
Improvements:\n\
- [Abot Kamay] Added Abot Kamay animation\n\
- [Abot Kamay] Automatically pull up when OSK is shown\n\
- [Abot Kamay] Change behavior and target height on external display\n\
- [Auto-Brightness DIY] Do not change brightness if there's near proximity is detected\n\
- [Awake Tracking] Improved Awake tracking logic\n\
- [Battery Tracking] Attempt to always update the last full charge time\n\
- [Battery Tracking] Make sure invalid date are not added to the tracking data i.e. when system has incorrect date at boot\n\
- [Color Overlay] Converted toggles to toggle sensor-based instead of the actual enabling of Color Overlay\n\
- [Drawer] Added haptics when clicking apps\n\
- [Drawer] Added more bottom margin to the indicator selector when in external display and tall displays\n\
- [Dynamic Cove] Better readbility of song details in the CD Player\n\
- [Dynamic Cove] Made Dynamic cove usable with Mouse\n\
- [Dynamic Cove] Improved accuracy when setting the Timer\n\
- [Dynamic Cove] Tweaks in the Media Player's playlist selection\n\
- [Dynamic Cove] Adjust size on big scaled devices (i.e. Lenovo M10 HD)\n\
- [Fingerprint] Turn on display when fingerprint is enabled while screen is off and you are locked out even when it's still a failed scan\n\
- [Indicator Panels] Respect Expandable header settings even when inverted\n\
- [Indicator Panels] Automatically collapse header when the on-screen keyboard is displayed\n\
- [Indicator Panels] Automatically collapse header when Quick Toggles is expanded and automatically collapse quick toggles when panel header is expanded\n\
- [Outer Wilds] Adjust Main Menu size on big scaled devices (i.e. Lenovo M10 HD)\n\
- [Outer Wilds] Adjusts detection of large screen for spacing and sizing of elements\n\
- [Pocket Mode] Do not enter pocket mode when there's an external display\n\
- [Quick Actions] Implemented different styles (i.e. Default, Circular and Rounded Square)\n\
- [Quick Actions] Added media controls - play, next, previous\n\
- [Quick Actions] Less subtle visual hint\n\
- [Quick Actions] Show visual hint when in settings page\n\
- [Quick Actions] Rearranged and grouped the settings page\n\
- [Quick Actions] Disable haptics when not swiping\n\
- [Quick Actions] Make search drawer action always search instead of toggling the drawer\n\
- [Quick Actions] Search drawer action will now work properly when triggered from the lockscreen\n\
- [Quick Toggles] Implement right click to function the same as press and hold\n\
- [Quick Toggles] Make media controls usable with mouse\n\
- [Settings] Button to hide the settings page\n\
- [Show Desktop] Revert back show desktop when an app is opened or refocused\n\
- [Top Bar] Minor tweak to behavior when top bar matches the current app. It won't change until the current app is change or spread is completely shown instead of immediately when edge drag/push is in-progress\n\
- [Top Panel] Use wallpaper as blur source when there's no main stage app and side-stage is hidden\n\n\n\
Bug Fixes:\n\
- [Advanced Screenshot] Fixed layout of Share popup in wide layout\n\
- [Advanced Screenshot] Fixed hover breaking when screenshot popup is dismissed by tapping outside or the close button\n\
- [Battery Tracking] Fixed incorrect date in battery tracking when booting\n\
- [Dynamic Cove] Fixed Disco mode not working\n\
- [Dynamic Cove] Fixed CD player hiding when screen is off when blur is enabled\n\
- [Hot corners] Fixed bug where toggle desktop also swicth to previous app\n\
- [Quick Actions] Fixed highlighted item overlapped by some surrounding actions\n\
- [Quick Actions] Fixed label clipping on the side\n\
- [Shell] Work around to fix Never games and other games that has incorrect orientation\n\
- [Keyboard Shortcut] Fix terminal keyboard shortcut\n\
- [Settings] Fixed App Grids in Features page\n\
- [Top Panel] Fixed issues with proper matching of top panel when drawer or indicator panel is open\n\n\n\
Technical:\n\
- Implmented Lomiri MR#191 and MR#213 to fix stutters when toggling fullscreen\n\
- Updated code for rotate button from MR\n\
- Made some icons load asynchronously\n\
- Fixed bug related to 'maximizeWindowShortcut'\n\n\n\
v2.2\n\
New Features:\n\
- Auto-brightness DIY: Added option to make your own auto-brightness behavior\n\
- Advanced Screenshot: Provide direct access to actions such as sharing and editing of screenshots\n\
- Battery Tracking: Added option to track screen on and off time and options to display the data in the Battery indicator\n\
- Fingerprint: Added option to enable the sensor even when the display is off and also added other options\n\
- Fully Charged Alarm: Option to trigger an alarm when the device is fully charged or reached your set percentage\n\
- Indicators: Added option to show bluetooth devices list in the Bluetooth indicator panel\n\
- Light Sensor: Added option to allow automatically enabling Color Overlay and Dark Mode based on light sensor\n\
- Lockscreen: Added option to change display name and use custom icon\n\
- Notifications: Add option to display notification bubbles at the bottom\n\
- Pocket Mode: All touch interactions are disabled when proximity sensor detects something near and the light sensor detects darkness\n\
- Snatch Alarm: Set a contact that when it calls, silent mode is automatically disabled and volume is set to max\n\
- Top Bar: Added option to use custom color for the icons and texts (Only when collapsed for now)\n\
- Wake Up Alarms: Automatically disable wake up alarms until the next day once you press the awake in the lockscreen\n\
- Waydroid Gestures: Added an option to disable a portion of the left and right edge gestures so you can use Waydroid gesture-based navigation\n\
- Added option to disable shutdown and reboot options when in lockscreen. They can still be accessed by doing an extra step.\n\
\n\
Improvements:\n\
- App Drawer: Added mouse hover area at the top/bottom to start search when the field is hidden\n\
- App Drawer Dock: Added maximum expanded height settings\n\
- Dynamic Cove: Added ambient mode in the media controls which overlays the current album art in your lockscreen\n\
- Dynamic Cove: Added option to not hide CD Player when screen is off\n\
- Quick Actions: Select Edge items when swipe exceeds the grid\n\
- Quick Actions: Added search drawer action\n\
- Quick Toggles: Added a settings for disabling indicator toggles when the device is locked\n\
- Quick Toggles and Drawer Dock: Improved swipe gesture for expanding/collapsing\n\
- Quick Toggles and Drawer Dock: Properly handle when expanded height exceeds the available height by making it scrollable\n\
- Notifications: Disable swipe to dismiss for incoming calls\n\
- Added subtle color change in the side-stage divider to indicate which stage is currently in focus\n\
- Added option to automatically pause the media upon disconnecting a Bluetooth audio device\n\
- Adjust the App splash image size based on window size when in windowed mode\n\
- Added Features page in settings to consolidate all major features in Lomiri Plus\n\
\n\
Fixes:\n\
- App Drawer: Fixed issues with mouse and multirow use in the selector indicator\n\
- Dynamic Cove: Reload the media player object to try to fix when playing a playlist does nothing\n\
- Launcher: Fixed noticeable change of color when quickly opening the Drawer by removing the animation\n\
- Quick Actions: Fixed issue where sometimes quickly swiping will trigger the left/right edge most item\n\
- Top Bar: Fixed blur background when using show desktop\n\
- Fixed binding loop in indicator panels\n\
- Fixed some misplaced items in Lomiri Plus settings\n\
- Changed remaing labels of Direct Actions to Quick Actions\n\
\n\
Technical: \n\
- Dynamic Cove: Use `Audio` instead of `MediaPlayer` for the media player\n\
- Disable bottom gestures from MariKit in indicator panels (rely on MariKit changes)\n\n\n\
v2.1 \n\
General:\n \
- Added option to show touch visuals (only works with one touchpoint and don't work perfectly)\n \
- Apply custom BFB logo settings even when not using custom logo\n \
- Added color and opacity settings for the Launcher, App Drawer, Top Bar and Indicator Panels\n \
- Added option to use the wallpaper as source of all background blurs\n \
- Added option to change Launcher opacity based on Drawer's open/close progress\n \
- Added option to add bottom margin to the Launcher based on the rounded corner margin in Device Configuration when in Staged mode\n \
- Added option to match Top Bar's opacity and color to Drawer or Indicator panel when they are open\n \
- Added option to enable background blur to the Top Bar and Launcher\n \
- Added option to match the Top Bar's background to the current app's top part color (Staged mode only)\n \
- Added option to make Top Bar fully transparent in the lockscreen\n \
- Added swipe down gesture from the top edge to show the Top Bar when in fullscreen\n \
- Added settings for delaying app suspension upon opening an app and/or everytime it goes to the background\n \
- Made selecting from the App Grid indicator selector easier when there's only 1 row\n \
- Made the touch area in the App Grid indicator selector a bit bigger\n \
- Renamed Direct Actions to Quick Actions\n \
- Made Direct Actions UI more consistent across different scaling and made it centered for most phones in portrait\n \
- Direct actions can now be opened via Hot Corners\n \
- Added option to use Direct Actions via tapping instead of immediately commiting after releasing the swipe\n \
- Added new Direct Action type Custom URI which can be used to add custom actions via URI i.e. sms://0123456789\n \
- Added keyboard shortcut to open Direct Actions\n \
- Added edit mode in Direct Actions (Via Lomiri Plus settings)\n \
\n \
- Stop updating BackgroundBlur when display is off\n \
- Added option to disable Sensor Gestures when screen is off\n \
- Hide window titlebar when maximized so it won't show behind translucent Top Bar\n \
- Shorten Side-Stage handle so it won't show under the Top Panel\n \
- Added optional device hack for devices that has a problem with bottom gestures in certain orientations\n \
- Outer Wilds: Removed BFB appearance changes aside from the icon itself\n \
- Outer Wilds: Loading circle pauses when typing the passcode\n \
\n \
Fixes:\n \
- Disable lock screen, app screenshot and close app Direct Actions when in lockscreen\n \
- Do not hide Top Bar in Windowed mode\n \
- Corrected logic to always show the first screen in Workspaces unless there's multiple screens and in Virtual touchpad mode\n \
- Fixed focus when moving unfocused apps between Main and Side Stage. Automatically move them to the foreground.\n \
- Fixed issues with header collapse/expand in the Indicator Panels\n \
- Removed opacity animation of header label in Indicator Panels to avoid delayed animation when quickly expanding/collapsing\n \
- Fixed issue when resetting App Grids headers when inverted\n \
- Stop expanding the header of App Grids when in Windowed mode\n \
- Properly set Dark mode without using a hardcoded URL\n \
- Fixed Auto Dark Mode always triggering when rebooting or restarting Lomiri even if disabled\n \
- Fixed all hard coded paths to properly use standard user paths (custom wallpaper, custom BFB, etc)\n \
- Tries to limit battery drain in Dynamic Cove\n \
- Fixes in Outer Wilds themes\n \
\n \
Desktop/Windowed mode related:\n \
- Identify devices with touchscreen as tablet which makes the desktop mode toggle actually work to swicth to Staged mode\n \
- Added options to enable more advanced keyboard shortcuts for snapping windows - added quarter snapping to the shortcut, replace horizontal and vertical snapping to top and bottom snapping and delayed snapping \n \
- Added option to set custom window snapping preview colors\n \
- Switch between workspaces with 4 finger swipe gesture. 5 finger to move current app to selected workspace\n \
- Implemented keyboard shortcut for moving current app while switching workspace\n \
- Added option to delay Workspace Switcher UI when quickly switching\n \
- Enabled short swipe to switch to previous app in windowed mode\n \
- Added option to enlarge window buttons when window resize/move touch controls are displayed\n \
- Added option to match window titlebar with app's top part color\n \
- Automatically switch to the workspace of the app getting focused\n \
- Fixed maximized apps getting restored when switching workspace\n \
- Fixed maximized/snapped and fullscreen windows getting unnecessarily resized when entering spread, in the spread and when minimized\n \
- Fixed transition animation from minimized to maximized/snapped\n \
- Fixed minimize animation to actually show\n \
- Fixed Spread showing in inncomplete state when switching workpsace then using the keyboard shortcut/Hot Corner to open the Spread\n \
- Fixed window control buttons still show up in the Top Bar when closing a maximized app that is the only app open\n \
- Workspace preview fixes such as correct sizing for maximized/snapped windows and in Staged mode (still not perfect though), changing size based on screen orientation, screen size and aspect ratio with consideration ofthe Launcher and top panel\n \
- Added option to enable less sensitive edge barriers for activating the left and right edge via mouse (For opening the Drawer and Spread)\n \
- Fixed App Grid issue on the desktops\n \
- Proper mouse navigation support in the App Grid indicator selector\n \
- Wonky Wobbly Windows :)\n \
- Optional Spread workaround in Ubuntu desktop where apps steal touch events\n \
- Added option to disable keyboard shortcuts overlay\n \
\n \
Device Specific:\n \
Fxtec Pro1-X\n \
 - Added Quick toggle, Direct actions and auto behaviors settings for the keypad backlight settings\n \
\n \
- Blue 💀"
        }
    ]
}
