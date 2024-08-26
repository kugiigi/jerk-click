import QtQuick.Controls 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12

BaseButton {
	id: actionButton

	property alias iconName: icon.name

    backgroundColor: theme.palette.normal.foreground
    focusPolicy: Qt.NoFocus
    
	UT.Icon {
		id: icon
		
		implicitWidth: actionButton.width * 0.6
		implicitHeight: implicitWidth
		anchors.centerIn: parent
		color: theme.palette.normal.foregroundText
	}
}
