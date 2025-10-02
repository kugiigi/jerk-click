import QtQuick 2.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import TweakTool 1.0
import "ListItems" as ListItems
import "../js/shell.js" as Shell

Item {
    id: rootItem

    readonly property string oldVersionSuffix: "_OLD"
    readonly property bool confirmedComponentIsDirty: componentWasChecked && !componentIsClean

    property string package_id
    property string packageName
    property string component_id
    property string componentName
    property string fileName
    property bool hasRestart: false

    property bool componentWasChecked: false
    property bool componentIsClean: false
    
    readonly property Timer delayedBlockOTATimer: Timer {
        interval: LomiriAnimation.BriskDuration
        onTriggered: {
            if (Shell.blockOTA()) {
                checkComponentIfClean()
                showFinishDialog("block-ota", true)
            } else {
                showFinishDialog("block-ota", false)
            }
            hideModalLoadingScreen()
        }
    }
    readonly property Timer delayedUnblockOTATimer: Timer {
        interval: LomiriAnimation.BriskDuration
        onTriggered: {
            if (Shell.unblockOTA()) {
                checkComponentIfClean()
                showFinishDialog("unblock-ota", true)
            } else {
                showFinishDialog("unblock-ota", false)
            }
            hideModalLoadingScreen()
        }
    }
    readonly property Timer delayedInstallTimer: Timer {
        property bool installOldVersion: false

        interval: LomiriAnimation.BriskDuration

        function startTimer(_old = false) {
            installOldVersion = _old
            restart()
        }
        
        onTriggered: {
            let _fileName = rootItem.fileName
            if (installOldVersion) {
                _fileName += rootItem.oldVersionSuffix
            }

            if (Shell.installPackage(_fileName)) {
                checkComponentIfClean()
                Shell.blockOTA()
                showFinishDialog("install", true)
            } else {
                showFinishDialog("install", false)
            }
            hideModalLoadingScreen()
        }
    }
    readonly property Timer delayedUninstallTimer: Timer {
        interval: LomiriAnimation.BriskDuration
        onTriggered: {
            if (Shell.uninstallPackage(rootItem.fileName)) {
                checkComponentIfClean()
                showFinishDialog("uninstall", true)
            } else {
                showFinishDialog("uninstall", false)
            }
            hideModalLoadingScreen()
        }
    }
    readonly property Timer delayedResetTimer: Timer {
        interval: LomiriAnimation.BriskDuration
        onTriggered: {
            if (Shell.resetComponent(rootItem.component_id)) {
                if (rootItem.component_id !== "all") {
                    checkComponentIfClean()
                }
                showFinishDialog("reset", true)
            } else {
                showFinishDialog("reset", false)
            }
            hideModalLoadingScreen()
        }
    }

    function checkComponentIfClean() {
        let _returnCode = Shell.checkComponentForMods(rootItem.component_id)
        componentIsClean = _returnCode
        componentWasChecked = true
    }

    function showModalLoadingScreen(_loadingText) {
        mainView.overlayContainer.showAsModal(_loadingText)
    }

    function hideModalLoadingScreen() {
        mainView.overlayContainer.hide()
    }

    function showFinishDialog(_action, _success) {
        let _popup = PopupUtils.open(finishDialog, parent, { "mode": _action
                                                                    , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName
                                                                    , "packageName": rootItem.packageName
                                                                    , "offerRestart": rootItem.hasRestart
                                                                    , "isSuccess": _success })

        _popup.restart.connect(function() {
            askToRestart()
        })
        _popup.reset.connect(function() {
            askToReset()
        })
    }

    function installPackage(_old = false) {
        showModalLoadingScreen(i18n.tr("Installing %1...").arg(rootItem.packageName))
        delayedInstallTimer.startTimer(_old)
    }

    function uninstallPackage() {
        showModalLoadingScreen(i18n.tr("Uninstalling %1...").arg(rootItem.packageName))
        delayedUninstallTimer.restart()
    }

    function resetComponent() {
        showModalLoadingScreen(i18n.tr("Resetting %1...").arg(rootItem.componentName))
        delayedResetTimer.restart()
    }

    function blockOTA() {
        showModalLoadingScreen(i18n.tr("Blocking OTA..."))
        delayedBlockOTATimer.restart()
    }

    function unblockOTA() {
        showModalLoadingScreen(i18n.tr("Unblocking OTA..."))
        delayedUnblockOTATimer.restart()
    }

    function askToInstall(_old = false) {
        let _popup = PopupUtils.open(confirmDialog, rootItem, { "mode": "install" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName
                                                                    , "package_id": rootItem.package_id
                                                                    , "packageName": rootItem.packageName
                                                                    , "componentIsDirty": rootItem.confirmedComponentIsDirty })

        _popup.accepted.connect(function() {
            installPackage(_old)
        })
    }

    function askToUninstall() {
        let _popup = PopupUtils.open(confirmDialog, rootItem, { "mode": "uninstall" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName
                                                                    , "package_id": rootItem.package_id
                                                                    , "packageName": rootItem.packageName
                                                                    , "componentIsDirty": rootItem.confirmedComponentIsDirty })

        _popup.accepted.connect(function() {
            uninstallPackage()
        })
    }

    function askToReset() {
        let _popup = PopupUtils.open(confirmDialog, rootItem, { "mode": "reset" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName })

        _popup.accepted.connect(function() {
            resetComponent()
        })
    }

    function askToRestart() {
        let _popup = PopupUtils.open(confirmDialog, rootItem, { "mode": "restart" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName })

        _popup.accepted.connect(function() {
            switch (rootItem.component_id) {
                case "lomiri":
                    Shell.restartLomiri()
                    break
                case "maliit-keyboard":
                case "maliit-keyboard-layouts":
                    Shell.restartMaliit()
                    break
                case "dialer-app":
                    Shell.restartDialerApp()
                case "system-settings":
                    Shell.restartSettingsApp()
                    break
            }
        })
    }
    
    function askToBlockOTA() {
        let _popup = PopupUtils.open(confirmDialog, parent, { "mode": "block-ota" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName
                                                                    , "package_id": rootItem.package_id
                                                                    , "packageName": rootItem.packageName
                                                                    , "componentIsDirty": rootItem.confirmedComponentIsDirty })

        _popup.accepted.connect(function() {
            blockOTA()
        })
    }

    function askToUnblockOTA() {
        let _popup = PopupUtils.open(confirmDialog, parent, { "mode": "unblock-ota" , "component_id": rootItem.component_id
                                                                    , "componentName": rootItem.componentName
                                                                    , "package_id": rootItem.package_id
                                                                    , "packageName": rootItem.packageName
                                                                    , "componentIsDirty": rootItem.confirmedComponentIsDirty })

        _popup.accepted.connect(function() {
            unblockOTA()
        })
    }
    
    Component {
        id: confirmDialog
        Dialog {
            id: confirmDialogue

            signal accepted

            property string mode: "restart"
            property string package_id
            property string packageName
            property string component_id
            property string componentName
            property bool componentIsDirty: false

            readonly property bool isRestart: mode === "restart"
            readonly property bool isInstall: mode === "install"
            readonly property bool isUninstall: mode === "uninstall"
            readonly property bool isReset: mode === "reset"
            readonly property bool isBlockOTA: mode === "block-ota"
            readonly property bool isUnblockOTA: mode === "unblock-ota"

            readonly property string resetSuggestionText: i18n.tr("You can try the 'Reset %1' button or reflash (without wipe) via UBports Installer to restore the clean version").arg(componentName)
            readonly property string dirtyNote: {
                return (componentIsDirty ? i18n.tr("%1 currently has modifications installed. It is highly recommended to reset the component first or uninstall these modifications. ").arg(componentName)
                    + i18n.tr("Multiple installed packages in a single component is not recommended as it has higher chance for conflicts and issues.")
                    + "\n\n"
                    : "")
            }
            readonly property string extraNote: {
                if (isRestart) {
                    switch (component_id) {
                        case "lomiri":
                            return [i18n.tr("This will restart the whole system UI and close all your open apps. Save your work before proceeding.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart, your device will be totally unusable until you reflash (without wipe).").arg(componentName)
                                    , i18n.tr("Make sure you have access to UBports Installer, just in case.")
                                    , , resetSuggestionText].join(" ")
                            break
                        case "maliit-keyboard":
                        case "maliit-keyboard-layouts":
                            return [i18n.tr("This will restart the on-screen keyboard.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart, you won't be able to type or even login to your device without a physical keyboard or biometric login.").arg(componentName)
                                    , , resetSuggestionText].join(" ")
                            break
                        case "dialer-app":
                            return [ i18n.tr("This will restart the Dialer app.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart, you won't be able to open the %1 and make or receive any call.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        case "system-settings":
                            return [ i18n.tr("This will restart the System Settings app.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart, you won't be able to open the %1 and change any setting.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        default:
                            return ""
                    }
                }

                if (isInstall) {
                    let _finalText = ""
                    switch (component_id) {
                        case "lomiri":
                            _finalText = [ i18n.tr("This will modify %1, the desktop environment or system UI.").arg(componentName)
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, your device will be totally unusable until you reflash (without wipe).").arg(componentName)
                                    , i18n.tr("Make sure you have access to UBports Installer, just in case.")
                                    , resetSuggestionText].join(" ")
                            break
                        case "maliit-keyboard":
                        case "maliit-keyboard-layouts":
                            _finalText = [ i18n.tr("This will modify the on-screen keyboard.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, you won't be able to type or even login to your device without a physical keyboard or biometric login.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        case "bluetooth_conf":
                            _finalText = [ i18n.tr("This will modify the Bluetooth configuration.")
                                    , i18n.tr("\n\nWARNING: If the configuration changes cause an error, you may not be able to use any Bluetooth function.")
                                    , resetSuggestionText].join(" ")
                            break
                        case "uitk":
                            _finalText = [ i18n.tr("This will modify the Lomiri Toolkit.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, all apps that use it will fail to open, including this app.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        case "dialer-app":
                            _finalText = [ i18n.tr("This will modify the Dialer app.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, you won't be able to open the Dialer app and make or receive any call.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        case "system-settings":
                            _finalText = [ i18n.tr("This will modify the System Settings app.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, you won't be able to open the System Settings app and change any setting.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        case "webcontainer":
                            _finalText = [ i18n.tr("This will modify the Web app container.")
                                    , i18n.tr("\n\nWARNING: If %1 fails to restart after installation, all web apps will stop working and won't open.").arg(componentName)
                                    , resetSuggestionText].join(" ")
                            break
                        default:
                            return ""
                    }

                    return [dirtyNote, _finalText].join(" ")
                }

                if (isUninstall) {
                    return [i18n.tr("This will try to uninstall %1. This is a cleaner way of uninstalling as it cleans up all files.").arg(packageName)
                            , i18n.tr("However, this may take a long time to finish especially with big packages like Lomiri Plus.")
                            , i18n.tr("If this fails, try the 'Reset' function which will revert all modified files in %1 to their original copies and it's a faster process.").arg(componentName)
                            , i18n.tr("New files will be retained though. Reflash (without wipe) to get a clean install of %1").arg(componentName)
                            ].join(" ")
                }

                if (isReset) {
                    return i18n.tr("This will reset %1 and remove all modifications").arg(componentName)
                }

                if (isBlockOTA) {
                    return [
                            i18n.tr("This will block OTA updates via the System Settings app.")
                            , i18n.tr("This is to prevent accidental update that may cause conflicts and issues.")
                            , i18n.tr("Delta OTA updates only update parts of the system and has a higher chance of conflicting with our modifications.")
                    ].join(" ")
                }

                if (isUnblockOTA) {
                    return [
                            i18n.tr("This will unblock OTA updates via the System Settings app.")
                            , i18n.tr("\n\nIt is highly recommended to reset all components instead of unblocking manually.")
                    ].join(" ")
                }

                return ""
            }

            title: {
                if (isRestart) {
                    return i18n.tr("Restart %1").arg(componentName)
                }
                if (isInstall) {
                    return i18n.tr("Install %1").arg(packageName)
                }
                if (isUninstall) {
                    return i18n.tr("Uninstall %1").arg(packageName)
                }
                if (isReset) {
                    return i18n.tr("Reset %1").arg(componentName)
                }
                if (isBlockOTA) {
                    return i18n.tr("Block OTA Updates")
                }
                if (isUnblockOTA) {
                    return i18n.tr("Unblock OTA Updates")
                }

                return ""
            }
            text: extraNote !== "" ? extraNote : ""

            Button {
                text: {
                    if (confirmDialogue.isRestart) {
                        return i18n.tr("Restart")
                    }
                    if (confirmDialogue.isInstall) {
                        return confirmDialogue.componentIsDirty ? i18n.tr("Install Anyway") : i18n.tr("Install")
                    }
                    if (confirmDialogue.isUninstall) {
                        return i18n.tr("Uninstall")
                    }
                    if (confirmDialogue.isReset) {
                        return i18n.tr("Reset")
                    }
                    if (confirmDialogue.isBlockOTA) {
                        return i18n.tr("Block OTA")
                    }
                    if (confirmDialogue.isUnblockOTA) {
                        return i18n.tr("Unblock OTA")
                    }

                    return i18n.tr("Proceed")
                }
                color: {
                    switch(true) {
                        case confirmDialogue.isRestart:
                        case confirmDialogue.isReset:
                        case confirmDialogue.isUninstall:
                        case confirmDialogue.isBlockOTA:
                            return theme.palette.normal.negative
                    }

                    if (confirmDialogue.componentIsDirty) {
                        return theme.palette.normal.base
                    }

                    return theme.palette.normal.positive
                }
                onClicked:  {
                    confirmDialogue.accepted()
                    PopupUtils.close(confirmDialogue)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(confirmDialogue)
            }
        }
    }

    Component {
        id: finishDialog
        Dialog {
            id: finishDialogue

            signal restart
            signal reset

            property string mode: "install"
            property string package_id
            property string packageName
            property string component_id
            property string componentName
            property bool offerRestart: false
            property bool isSuccess: false

            readonly property bool isInstall: mode === "install"
            readonly property bool isUninstall: mode === "uninstall"
            readonly property bool isReset: mode === "reset"
            readonly property bool isBlockOTA: mode === "block-ota"
            readonly property bool isUnblockOTA: mode === "unblock-ota"

            readonly property string otaBlockedText: [
                i18n.tr("OTA updates are blocked in the System Settings app until you use the 'Reset All' or 'Unblock OTA Updates' function in this app.")
                , i18n.tr("This is to avoid conflicts with delta OTA updates.")
            ].join(" ")
            readonly property string restartText: {
                switch (component_id) {
                    case "lomiri":
                    case "maliit-keyboard":
                    case "maliit-keyboard-layouts":
                    case "dialer-app":
                    case "system-settings":
                        return i18n.tr("Restart %1 to make the changes take effect.").arg(componentName)
                    case "bluetooth_conf":
                        return i18n.tr("Reboot to make the changes take effect.")
                    case "uitk":
                        return i18n.tr("Apps have to be restarted before the changes take effect.")
                    case "webcontainer":
                        return i18n.tr("Web apps have to be restarted before the changes take effect.")
                    default:
                        return ""
                }
            }

            title: {
                if (isInstall) {
                    return isSuccess ? i18n.tr("Installed successfully") : i18n.tr("Installation Failed")
                }
                if (isUninstall) {
                    return isSuccess ? i18n.tr("Uninstalled successfully") : i18n.tr("Uninstallation Failed")
                }
                if (isReset) {
                    return isSuccess ? i18n.tr("Reset successful") : i18n.tr("Reset Failed")
                }
                if (isBlockOTA) {
                    return isSuccess ? i18n.tr("OTA Updates successfully blocked") : i18n.tr("Failed to block OTA updates")
                }
                if (isUnblockOTA) {
                    return isSuccess ? i18n.tr("OTA Updates successfully unblocked") : i18n.tr("Failed to unblock OTA updates")
                }

                return ""
            }
            text: {
                if (isInstall) {
                    return isSuccess ? [i18n.tr("%1 was successfully installed.").arg(packageName)
                                        , otaBlockedText
                                        , restartText].join(" ")
                                : [i18n.tr("%1 cannot be installed. It may not be compatible with your system or you already have this package installed.").arg(packageName)
                                    , i18n.tr("Try uninstalling or resetting %1 and try again.").arg(componentName)].join(" ")
                }
                if (isUninstall) {
                    return isSuccess ? [i18n.tr("%1 was successfully uninstalled.").arg(packageName)
                                        , restartText].join(" ")
                                : [i18n.tr("%1 cannot be uninstalled. This package may not be installed yet.").arg(packageName)
                                    , i18n.tr("Try resetting %1 instead.").arg(componentName)].join(" ")
                }
                if (isReset) {
                    return isSuccess ? [i18n.tr("%1 was successfully reset.").arg(componentName)
                                        , restartText].join(" ")
                                : [i18n.tr("%1 cannot be reset. An unexpected issue was encountered.").arg(componentName)
                                    , i18n.tr("Please contact the developer.")].join(" ")
                }
                if (isBlockOTA) {
                    return isSuccess ? [i18n.tr("OTA updates via System Settings app has been blocked.")
                                        , i18n.tr("Use the 'Unblock OTA Updates' or 'Reset All Components' function to re-enable OTA updates")].join(" ")
                                : [i18n.tr("OTA updates cannot be blocked..")
                                    , i18n.tr("OTA updates might be blocked already or this app needs to be updated.")].join(" ")
                }
                if (isUnblockOTA) {
                    return isSuccess ? [i18n.tr("OTA updates via System Settings app has been re-enabled.")
                                        , i18n.tr("Make sure you have no remaining modifications installed before applying an OTA update.")
                                        , i18n.tr("This is to avoid any conflict between our modifications and system updates.")
                                        ].join(" ")
                                : [i18n.tr("OTA updates cannot be unblocked..")
                                    , i18n.tr("OTA updates might not be blocked yet or this app needs to be updated.")].join(" ")
                }

                return ""
            }

            Button {
                visible: finishDialogue.offerRestart && finishDialogue.isSuccess
                text: i18n.tr("Restart %1").arg(componentName)
                color: theme.palette.normal.negative

                onClicked:  {
                    finishDialogue.restart()
                    PopupUtils.close(finishDialogue)
                }
            }

            Button {
                visible: (finishDialogue.isInstall || finishDialogue.isUninstall) && !finishDialogue.isSuccess
                text: i18n.tr("Reset %1").arg(componentName)
                color: theme.palette.normal.negative

                onClicked:  {
                    finishDialogue.reset()
                    PopupUtils.close(finishDialogue)
                }
            }

            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(finishDialogue)
            }
        }
    }
}
