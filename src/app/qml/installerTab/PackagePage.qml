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
    readonly property bool shoudBeVisible: packageData && packageData.visible

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
            , "visible": true
            , "description": "Malakiboard is a collection of hacks, modifications, and mods for the Lomiri keyboard used in Ubuntu Touch. \
It is Kugi's playground for fixes, changes and new features that may or may never land on the upstream Lomiri keyboard. \
\n\n****************  IMPORTANT ****************\n\
Additional settings can be accessed by long pressing the language switcher/emoji key and selecting 'Malakiboard Settings' at the bottom.\
\n**********************************************\
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
            , "changelog": "v1.9\n\
- 24.04-1.4 Compatibility\n\
- Fixes regressions and conflicts with the new update i.e layout issue when switching to symbols\n\
- Improves display of word ribbon when Shorcuts Bar is enabled\n\
- Do not force show word ribbon when Notebook feature is enabled. Only force show when Shortcuts bar is enabled\n\
- Hide Emoji and Language actions when in numbers and telephone layouts\n\n\
v1.8\n\
- Fixed clipping in the Notebook list views\n\
- Added option to use custom display pixel density. Useful for devices like the Faiphone 5 which has an incorrect pixel density. This affects gestures that use physical sizing.\n\
- Fixed errors related to `keyboardRect` in MKBaseDialog\n\n\n\
v1.7\n\
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
            , "old_version": false
            , "visible": true
            , "description": "This is a companion package for Malakiboard which includes changes specific to languages/layouts. Install this if you installed Malakiboard to get the full functionalities and features."
            , "screenshots": []
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Keyboard/MalakiboardLayouts"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": ""
        }
        , {
            "package_id": "sapot_container"
            , "file_name": "SapotContainer"
            , "old_version": true
            , "visible": true
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
            , "changelog": "v1.5\n\
- Added option to make the bottom gesture area not overlap the webview. Default is to not overlap\n\
- New quick action for opening the general context menu\n\
- Added Find in page function in the general context menu\n\
- Fixed zoom dialog showing up at startup when the default zoom level isn't 100%\n\n\n\
v1.4\n\
- Fixed issue when dragging the floating scroll button where it momentarily jumps to the top before going back to correct position\n\
- Quick action items do not hide when disabled anymore. This helps make the position of items predicatable instead of constantly changing based on item's enablement.\n\
- Added hover UI when toggling the header with the mouse and also extended the amount of time before the header shows up\n\
- Sync zoom value to Zoom settings when zooming via Ctrl + mouse scroll \n\
- Added option to list URLs/patterns which will be forced as external links regardless if it's from the internal domain/subdomain of the webpp. This is useful for sneaky bastards that user their own domain to redirect to external links.\n\n\n\
v1.3\n\
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
            , "old_version": true
            , "visible": true
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
            , "changelog": "v1.4\n\
- Fixed bug where header swipe won't work one time after pressing a header button\n\n\
v1.3\n\
- Make vertical scrollbars more usable with touch. When dragging a flickable, side margin is added to the scrollbar thumb to avoid conflict with side gestures and also the touch detection area becomes wider.\n\n\
v1.2\n\
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
            , "visible": true
            , "description": "** Recommended for devices with rounded corners and/or display cutout/notch **\n\n\
This is a minimal version of Lomiri Plus that only includes fixes, changes and new features that are 'essential' such as Notch and Rounded Corners support. \
\n\n****************  IMPORTANT ****************\n\
Additional settings can be accessed from the System indicator at the rightmost of Indicators \
\n**********************************************\n\n\
Notable features:\n \
- Device configuration for setting notch and rounded corner dimensions to adjust the UI accordingly \n \
- Option to enable Side-stage. Splitscreen-like feature that is enabled in landscape orientation. Apps can be dragged between stages with 3-finger drag. 3-finger tap will show/hide the Side-stage\n \
- Floating button that appears when rotating the device while screen orientaion is locked. Pressing this button will rotate the screen based on the physical orientation of the device.\n \
- Various indicator settings/options such as always hiding/showing icons in the top bar"
            , "screenshots": ["1.png", "2.png", "3.png", "4.png"]
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Lomiri/Lomiri_Plus_Essentials"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v1.2\n\
- Properly support left notch/punchhole by adding margins in the indicators\n\n\n\
v1.1\n\
- Fixed blur in Drawer and Indicator Panel\n\
- Work around to fix Never games and other games that has incorrect orientation\n\n\n\
v1.0 \n\
- Initial release"
        }
        , {
            "package_id": "lomiri_plus"
            , "file_name": "LomiriPlus"
            , "old_version": true
            , "visible": true
            , "description": "** Not recommended for most users as this changes a lot of things which makes it more prone from unexpected results such as higher battery drain and worse system performance. \
Install at your own risk! **\n\n\
Lomiri Plus is Kugi's playground for all his experiments in Lomiri. It includes fixes, changes, new features and random things that may or may never land in upstream Lomiri. \
This is a big package that changes many things in Lomiri. This is not professionally made and may or may not include some surprises. \
\n\n****************  IMPORTANT ****************\n\
Lomiri Plus settings can be accessed from the System indicator at the rightmost of Indicators or by swiping up from the bottom of the lockscreen, if enabled. \
\n**********************************************\n\n\
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
            , "sourceUrl": "https://github.com/kugiigi/jerk-packages/tree/main/Lomiri/Lomiri_Plus"
            , "developer": "Kugi Eusebio"
            , "devUrl": "https://github.com/kugiigi"
            , "changelog": "v2.5\n\
New Features:\n\n\
- [Quick Actions] Added new actions: Play all songs, Play 'Favorites' playlist\n\
- [Workspaces] Workspaces has been redesigned so switching between them is now seamless and without delay when reloading all windows/apps\n\
- [Workspaces] Added a new behavior when using keyboard  shortcuts for switching between workspaces\n\
- [Workspaces] Added shortcut to switch between workspaces by scrolling over the Launcher panel or Top bar\n\
\n\n\
Improvements:\n\n\
- [App Grids] Made animation when switching between pages faster\n\
- [Dynamic Cove] Also hide dimming when overlay hides and minor tweaks to the other border\n\
- [Drawer Advanced Search] Do not anchor to OSK when app grid/list is inverted. This improves performance when initiating search mode.\n\
- [Detox Mode] Changed Detox mode sliders to be based on seconds instead of minutes for better fine control\n\
- [Detox Mode] Added duration setting for the fun pages that appears\n\
- [Detox Mode] New Horror page\n\
- [Emoji Selector] Added recent list\n\
- [Extras] Changed delay sliders to be based on seconds instead of minutes for better fine control\n\
- [Fully Charge Alarm] Disable dialog popup on external displays\n\
- [Indicator Selector] Added an option to immediately select items upon highlighting them. This affects App grids and indicator panels\n\
- [Shell] Added haptics to various buttons such as settings slider buttons\n\
\n\n\
Bug fixes:\n\n\
- [App Spread] Fixed workspace preview for side-stage apps\n\
- [App Drawer] Fixed refresh not working when the search field is displayed\n\
- [Detox Mode] Fixed pausing timer when showing desktop\n\
- [Dynamic Cove] Improve work around when playing a playlist sometimes won't actually play the first song\n\
- [Indicator Panels] Fixed blur and transparency of the handle when inverted\n\
- [Top Bar] Fixed top bar full transparency optional settings when blur is disabled\n\
\n\n\n\
v2.4\n\
New features:\n\n\
- [Advanced Search] Implemented a new custom Drawer search page which includes optional OpenStore and Web results\n\
- [Air Mouse] Implemented custom click behavior where you swipe to trigger mouse clicks and drags\n\
- [Air Mouse] Changed swipe behavior from vertical to horizontal. Swipe to right is now right click and swipe to left is for dragging a window\n\
- [Air Mouse] Option to use volume buttons for left and right click\n\
- [App Spread] Option for a redesigned highlight UI\n\
- [Battery Tracking] List view option for the battery graphs by long pressing to toggle between the two view modes\n\
- [Device Configuration] Option to use custom display pixel density for devices with incorrect value such as the Fairphone 5. This affects gestures and UI elements that use physical size\n\
- [Dynamic Cove] Added option to automatically hide the information texts in the CD player after a set period of time\n\
- [Emoji Selector] New Emoji selector popup that can be opened via Ctrl + . (period) or Quick Actions that can be used to search and enter emojis\n\
- [Fingerprint] Added option to disable fingerprint while typing your passcode. Helpful to avoid accidentally touching side-mounted fingerprint sensors while typing.\n\
- [Indicator Panels] Added option to display expanded top bar with transparency matching the indicator panels\n\
- [Infographics] Option to display a custom text and random circles\n\
- [Launcher] Added option to lock and always display the Launcher regardless of screen size or mode (Staged/Windowed)\n\
- [Lockscreen] Added option to change the dark background on the lock screen and cover page\n\
- [Navigation Buttons] Implemented Navigation Buttons similar to Android but adapted to functions in Ubuntu Touch/Lomiri\n\
- [Notifications] Added option to force light mode for the notification bubble\n\
- [Quick Toggles] Added option to show Quick Toggles only in Notification indicator except when on external display\n\
- [Top Bar] Added option to make the top bar fully transparent when on the desktop and also change the text/icon color\n\
- [Virtual Touchpad] Added option to enable edge gestures for toggling the Drawer, the Spread, Indicators panels or even Quick Actions\n\
- [Virtual Touchpad] Added rotate button to rotate the touchpad\n\
- [Virtual Touchpad] Added multi-touch gestures for searching the App Drawer, switching workspace and dragging/resizing windows\n\
- [Virtual Touchpad] Added option to invert scrolling with the touchpad\n\
- [Virtual Touchpad] Added scroll sensitivity settings for the virtual touchpad scrolling\n\
- [Virtual Touchpad] Added 2-finger double tap to press and hold the right-click mouse button. Useful for dragging with right-click\n\
- [Windowed Mode] Added a way to resize a window with Alt + Right-click mouse drag\n\
\n\n\
Improvements:\n\n\
- [Air Mouse] Moved toggle from swipe from the bottom to a button at the top\n\
- [Battery Tracking] Added bottom spacing/margin in the Battery indicator panel\n\
- [Battery Tracking] Fixed extra icon in the average screen time menu item in the Battery indicator panel\n\
- [Detox Mode] New setting for the locked-in period instead of always being 24 hours\n\
- [Detox Mode] Timer for showing the 'fun page' now pauses when OSK is displayed and resumes after it is dismissed\n\
- [Detox Mode] Timer for showing the 'fun page' now pauses and resumes when switching between apps instead of restarting the timer\n\
- [Detox Mode] Timer for showing the 'fun page' now pauses and resumes in these conditions: Drawer is open/close, Indicator is open/close, Lockscreen is shown or not, desktop shown or not\n\
- [Drawer] Close Drawer when opening the App Spread\n\
- [Dynamic Cove] Hide Dynamic Cove on the desktop when there's an app focused and desktop isn't shown\n\
- [Dynamic Cove] Fixed quirks in Stopwatch where previous time is restored when it wasn't supposed to\n\
- [Dynamic Cove] Slightly darken the album art to improve legibility\n\
- [Dynamic Cove] Minor change in the CD player design to make it look more like a real CD\n\
- [Fingerprint] Also check temporary unlock via fingerprint when disabling actions or toggles on the lockscreen\n\
- [Hot Corners] Changed trigger behavior from hovering to pushing the mouse\n\
- [Indicator Panels] Added fallback icon in Indicator Selector for Time and Date indicator when there's no alarm\n\
- [Launcher] Stop showing the Launcher when clicking an empty workspace in the App Spread\n\
- [Lomiri Plus Settings] Reorganized some Launcher settings such as those related to Launcher locking/hiding to a separate page\n\
- [Lomiri Plus Settings] Added way to minimize the dialog\n\
- [Lomiri Plus Settings] Added way to go back to home page by double clicking or long pressing the back button\n\
- [Pocket Mode] Disable Pocket Mode detection when there's an external display\n\
- [Quick Actions] Power dialog action is now disabled when the device is locked\n\
- [Shell] Changed behavior of the 'Use timer for blur updates...' toggle and now affects both Staged and Windowed mode. Lomiri now enables live blur updates by default\n\
- [Shell] Improved Alt Tabbing by disabling mouse hover while it is in-progress\n\
- [Shell] Added a Welcome dialog for Lomiri Plus\n\
- [Shell] Showing desktop will close the Drawer and the Spread\n\
- [Virtual Touchpad] Added hint in the onscreen keyboard button when it's enabled or disabled\n\
- [Virtual Touchpad] Added option to reduce click threshold to avoid triggering left-click when doing small mouse movements\n\
\n\n\
Bug fixes:\n\n\
- [Detox mode] Fixed adding the first app from the combo box results to Unknown app\n\
- [Notch/Punchhole] Fixed left notch support on the indcators or top bar and battery circle\n\
- [Dynamic Cove] Fixed hour hand gets set as 25 instead of 1 in the Timer\n\
- [Dynamic Cove] Fixed swipe up gesture to show desktop conflicting with toggling the Dynamic Cove\n\
- [Dynamic Cove] Fixed issue when items don't fully load when rotating to landscape and back to portrait\n\
- [Hot Corners] Fixed issue where hot corners are triggered when trying to snap windows to quarter corners via mouse\n\
- [Indicator Panels] Fixed missing VoLTE icon\n\
- [Lockscreen] Fixed entering passcode via keyboard directly to the circle pattern pin prompt\n\
- [Lockscreen] Fixed backspace in the Circle pattern pin prompt\n\
- [Spread] Fixed Issue#150: Spread is broken when opened via keyboard after switching workspace via keyboard\n\
- [Spread] Fixed Issue#154/155: Binding loop error and Spread closing automatically when selecting the current workspace in the App Spread\n\
- [Spread] Fixed Issue#157: Incorrect workspace preview in switcher UI when in non-native orientation\n\
- [Windowed Mode] Fixed Issue#151: Double clicking top bar to restore window have incorrect restore position\n\
- [Windowed Mode] Fixed issue when in Windowed mode where maximized windows get resized when locking and unlocking because the Launcher gets hidden and shown\n\
\n\n\
Technical:\n\n\
- Updated indicator names/ids and added display indicator which has the rotation toggle now\n\
- Removed Screen rotation button settings since it's in Lomiri upstream now\n\
- Removed option to hide parenthesis in battery indicator since it's now removed by default in Noble\n\
- Fixed code errors related to Battery tracking and battery graph\n\
- Implmented logic to migrate data and settings to new names in Noble (Indicators and App IDs)\n\
- Fixed 2-digit format indicator clock in Noble\n\
- Disable swipe up gesture for disabling Show Desktop to allow swiping up to toggle Dynamic Cove on the desktop\n\
- Created custom button component\n\
- Updated LPFlickable with a function to scroll to item\n\
- Made action popovers narrower (units.gu(35))\n\
- Some adjustments and fixes for Light mode such as Lomiri Plus Settings and Indicator panels\n\
- Fixed icon source loading error in direct actions delegate\n\
\n\n\n\
v2.3\n\
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
- Fixed bug related to 'maximizeWindowShortcut'"
        }
    ]
}
