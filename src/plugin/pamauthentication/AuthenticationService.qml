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
 */
import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import com.ubuntu.PamAuthentication 0.1

/**
 A simple service for authentication.
 Displays login dialog and fires signals
 on access approval or denial.
 */
Item {
    id: authenticationService

    property alias serviceName: systemAuthentication.serviceName
    property string password

    signal granted()
    signal denied()

    Component.onCompleted: {
      //  if ( systemAuthentication.requireAuthentication() ) {
            displayLoginDialog();
      //  }
    }

    /**
     Displays the login dialog
     and fires success or failure depending
     on user input.
     */
    function displayLoginDialog() {
        var authentication_dialog =
            PopupUtils.open( Qt.resolvedUrl( "AuthenticationDialog.qml" ),
                             authenticationService );

        var verify_password = function( password ) {
            if ( systemAuthentication.validatePasswordToken( password ) ) {
                authenticationService.password = password;
                granted();
                PopupUtils.close( authentication_dialog );
            }
            else {
                var dialog_options = {
                    title : i18n.tr( "Authentication failed" )
                };

                PopupUtils.open( Qt.resolvedUrl( "NotifyDialog.qml" ),
                                 authenticationService,
                                 dialog_options );
            }
        };

        authentication_dialog.passwordEntered.connect( verify_password );
        authentication_dialog.dialogCanceled.connect( denied );
    }

    PamAuthentication { id: systemAuthentication }
}
