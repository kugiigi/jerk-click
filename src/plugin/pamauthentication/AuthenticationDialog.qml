/*
 * Copyright (C) 2014 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Arto Jalkanen <ajalkane@gmail.com>
 */
import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Dialog {
    id: root

    title: i18n.tr("Authentication required")

    text: i18n.tr("Enter passcode or passphrase:")

    signal passwordEntered(string password)
    signal dialogCanceled

    Component.onCompleted: {
        passwordField.forceActiveFocus();
    }

    TextField {
        id: passwordField
        objectName: "inputField"

        placeholderText: i18n.tr("passcode or passphrase")
        echoMode: TextInput.Password

        onAccepted: okButton.clicked(text)
    }

    Button {
        id: okButton
        objectName: "okButton"

        text: i18n.tr("Authenticate")
        color: theme.palette.normal.positive

        onClicked: {
            passwordEntered(passwordField.text)
            passwordField.text = "";
        }
    }

    Button {
        id: cancelButton
        objectName: "cancelButton"
        text: i18n.tr("Cancel")

        onClicked: {
            dialogCanceled();
        }
    }
}
