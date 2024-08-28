import QtQuick 2.4
import Lomiri.Components 1.3
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
                    text: actionsItem.confirmedComponentIsDirty ? i18n.tr("Install Anyway") : i18n.tr("Install")
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
            , "description": "Malakiboard is a collection of hacks, modifications, and mods for the Lomiri keyboard used in Ubuntu Touch. \
It is Kugi's playground for fixes, changes and new features that may or may never land on the upstream Lomiri keyboard. \
Additional settings can be accessed by long pressing the language switcher/emoji key and selecting 'Malakiboard Settings' at the bottom.\
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
            , "changelog": "v1.5 \n\
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
            , "description": "This is a companion package for Malakiboard which includes changes specific to languages/layouts. Ideally, this should be installed together with Malakiboard but this is optional unless you find issues."
            , "screenshots": []
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Keyboard/MalakiboardLayouts"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "bredr_fast"
            , "file_name": "Bluetooth_BRDER_FAST"
            , "description": "This changes controller mode from 'auto' to 'bredr' and enables 'FastConnectable'. This may fix some Bluetooth issues but there's no guarantee and battery drain may be higher. Feel free to try."
            , "screenshots": []
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Bluetooth_Conf/BREDR_FAST"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "settings_show_launcher"
            , "file_name": "Settings_ShowLauncher"
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
            , "changelog": "v1.1\n \
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
            , "changelog": "v1.1 \n \
- Settings implementation for gesture enablement and visual hint\n \
- Implemented swipe gesture on the header\n \
- Implemented back gesture animation in pages"
        }
        , {
            "package_id": "lomiri_plus_essentials"
            , "file_name": "LomiriPlus_Essentials"
            , "description": "** Recommended for devices with rounded corners and/or display cutout/notch **\n\n\
This is a minimal version of Lomiri Plus that only includes fixes, changes and new features that are 'essential' such as Notch and Rounded Corners support. \
Additional settings can be accessed from the System indicator at the rightmost of Indicators\n\n \
Notable features:\n \
- Device configuration for setting notch and rounded corner dimensions to adjust the UI accordingly \n \
- Option to enable Side-stage. Splitscreen-like feature that is enabled in landscape orientation. Apps can be dragged between stages with 3-finger drag. 3-finger tap will show/hide the Side-stage\n \
- Floating button that appears when rotating the device while screen orientaion is locked. Pressing this button will rotate the screen based on the physical orientation of the device.\n \
- Various indicator settings/options such as always hiding/showing icons in the top bar"
            , "screenshots": ["1.png", "2.png", "3.png", "4.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Lomiri/Lomiri_Plus_Essentials"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.0 \n\
- Initial release"
        }
        , {
            "package_id": "lomiri_plus"
            , "file_name": "LomiriPlus"
            , "description": "WARNING: Not recommended as this changes too much. Install at your own risk!\n\n\
Lomiri Plus is Kugi's playground for all his experiments in Lomiri. It includes fixes, changes, new features and random things that may or may never land in upstream Lomiri. \
This is a big package that changes many things in Lomiri. This is not professionally made and may or may not include some surprises. \
Lomiri Plus settings can be accessed from the System indicator at the rightmost of Indicators or by swiping up from the bottom of the lockscreen, if enabled.\n\n \
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
            , "changelog": "v2.1 \n\
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
