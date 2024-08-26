import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12

ItemDelegate {
    id: baseButton

    readonly property IconGroupedProperties secondaryIcon: IconGroupedProperties {
        width: Suru.units.gu(2)
        height: Suru.units.gu(2)
        color: Suru.foregroundColor
    }

    property bool interactive: true

    property alias radius: backgroundRectangle.radius
    property alias transparentBackground: backgroundRectangle.transparentBackground
    property alias backgroundColor: backgroundRectangle.backgroundColor
    property alias borderColor: backgroundRectangle.borderColor
    property alias highlightedBorderColor: backgroundRectangle.highlightedBorderColor
    property string tooltipText
    property int alignment: Qt.AlignCenter

    property alias label: mainLabel // Main label

    signal rightClicked(real mouseX, real mouseY)

    // TODO: Enable once UT's issue with hover is fixed
    hoverEnabled: false

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)

    display: AbstractButton.TextBesideIcon
    icon {
        width: Suru.units.gu(2)
        height: Suru.units.gu(2)
        color: Suru.foregroundColor
    }
    focusPolicy: Qt.TabFocus
    leftPadding: Suru.units.gu(1)
    rightPadding: leftPadding
    topPadding: Suru.units.gu(0.5)
    bottomPadding: topPadding

    Component {
        id: iconComponent

        UT.Icon {
            anchors.fill: parent
            name: baseButton.icon.name
            color: baseButton.icon.color
        }
    }

    Component {
        id: secondaryIconComponent

        UT.Icon {
            name: baseButton.secondaryIcon.name
            color: baseButton.secondaryIcon.color
            width: baseButton.secondaryIcon.width
            height: baseButton.secondaryIcon.height
        }
    }

    QtObject {
        id: internal
        
        readonly property bool centerContents: baseButton.display == AbstractButton.IconOnly
                                            || baseButton.display == AbstractButton.TextOnly
                                            || baseButton.alignment == Qt.AlignCenter
    }

    contentItem: Item {
        implicitHeight: layout.height
        implicitWidth: layout.width

        RowLayout {
            id: layout

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: internal.centerContents ? parent.horizontalCenter : undefined

            Loader {
                id: leftIconLoader

                Layout.preferredWidth: baseButton.icon.width
                Layout.preferredHeight: baseButton.icon.height
                Layout.alignment: internal.centerContents ? Qt.AlignCenter : Qt.AlignVCenter

                active: baseButton.icon.name !== ""
                visible: item ? true : false
                asynchronous: true
                sourceComponent: {
                    switch (baseButton.display) {
                        case AbstractButton.IconOnly:
                        case AbstractButton.TextBesideIcon:
                            return iconComponent
                        default:
                            return null
                    }
                }
            }

            Label {
                id: mainLabel

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: baseButton.text
                Suru.textLevel: baseButton.Suru.textLevel
                color: Suru.foregroundColor
                visible: opacity > 0
                opacity: {
                    switch (baseButton.display) {
                        case AbstractButton.TextOnly:
                        case AbstractButton.TextBesideIcon:
                        case AbstractButton.TextUnderIcon:
                            return 1
                        default:
                            return 0
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        easing: Suru.animations.EasingIn
                        duration: Suru.animations.FastDuration
                    }
                }
            }

            Loader {
                id: rightIconLoader

                Layout.preferredWidth: baseButton.icon.width
                Layout.preferredHeight: baseButton.icon.height
                Layout.alignment: Qt.AlignVCenter

                active: baseButton.secondaryIcon.name !== ""
                asynchronous: true
                visible: item ? true : false
                sourceComponent: {
                    switch (baseButton.display) {
                        case AbstractButton.TextUnderIcon:
                            return iconComponent
                        default:
                            if (baseButton.secondaryIcon.name) {
                                return secondaryIconComponent
                            } else {
                                return null
                            }
                    }
                }
            }
        }
    }

    background: BaseBackgroundRectangle {
        id: backgroundRectangle

        control: baseButton
        showDivider: false
        radius: Suru.units.gu(1)
    }

    MouseAreaContext {
        anchors.fill: parent

        onTrigger: baseButton.rightClicked(mouseX, mouseY)
    }

    ToolTip.delay: 1000
    ToolTip.visible: hovered && baseButton.tooltipText !== ""
    ToolTip.text: baseButton.tooltipText
}
