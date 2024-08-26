let _jerkInstallerPath = "bash ./qml/bin/jerk-installer/jerk"

function getJerkPackagePath(_fileName) {
    let _path = "packages/"
    return _path + _fileName + ".jerk"
}

function checkComponentForMods(_componentId) {
    let _cmd = [_jerkInstallerPath, "check-mods", _componentId].join(" ");
    let _useSudo = false
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole).indexOf("No Jerk modifications found") > -1;
}

function installPackage(_fileName) {
    let _cmd = [_jerkInstallerPath, "-p", "install", getJerkPackagePath(_fileName)].join(" ");
    let _useSudo = true
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole).indexOf("Installation has been completed successfully") > -1;
}

function uninstallPackage(_fileName) {
    let _cmd = [_jerkInstallerPath, "-p", "uninstall", getJerkPackagePath(_fileName)].join(" ");
    let _useSudo = true
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole).indexOf("Uninstallation has been completed successfully") > -1;
}

function resetComponent(_componentId) {
    let _useSudo = true
    let _incStdError = false
    let _logToConsole = true
    let _cmd = ""
    let _result = ""

    // Manually reset all since Jerk installer can't execute itself when ran from this app
    if (_componentId === "all") {
        let _array = mainView.componentList.slice()
        for (const _component of _array){
            if (_component.component_id !== "all") {
                if (resetComponent(_component.component_id) === false) {
                    return false
                }
            }
        }

        return true
    } else {
        _cmd = [_jerkInstallerPath, "-p", "reset", _componentId].join(" ");
        _result = processLaunch(_cmd, _useSudo, _incStdError, _logToConsole);
        return _result.indexOf("has been reset successfully") > -1 || _result.indexOf("Nothing to reset") > -1
    }
}

function restartLomiri() {
    let _cmd = "systemctl --user restart lomiri-full-greeter";
    let _useSudo = false
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole);
}

function restartSettingsApp() {
    let _cmd = "systemctl --user restart lomiri-app-launch--application-legacy--lomiri-system-settings--.service";
    let _useSudo = false
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole);
}

function restartMaliit() {
    let _cmd = "systemctl --user restart maliit-server";
    let _useSudo = false
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole);
}

function blockOTA() {
    let _cmd = [_jerkInstallerPath, "-p", "block-ota"].join(" ");
    let _useSudo = true
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole).indexOf("OTA updates are now blocked") > -1;
}

function unblockOTA() {
    let _cmd = [_jerkInstallerPath, "-p", "unblock-ota"].join(" ");
    let _useSudo = true
    let _incStdError = false
    let _logToConsole = true
    return processLaunch(_cmd, _useSudo, _incStdError, _logToConsole).indexOf("OTA updates will now work again") > -1;
}

function processLaunch(cmd, opt_useSudo, opt_incStdError, opt_logToConsole) {
    // Default values for optional parameters
    if (opt_useSudo === undefined) opt_useSudo = false;
    if (opt_incStdError === undefined) opt_incStdError = false;
    if (opt_logToConsole === undefined) opt_logToConsole = false;

    var wrapper = "/bin/bash -c \"";
    if (opt_useSudo) {
        wrapper += "echo " + pamLoader.item.password + " | sudo -S ";
    }
    wrapper += cmd + "\"";
    if (opt_logToConsole) {
        console.log(
            "processLaunch: " + wrapper.replace(pamLoader.item.password, "****")
        );
    }

    let _returnValue = Process.launch(wrapper, opt_incStdError);
    console.log("Shell: " + _returnValue)
    return _returnValue
}
