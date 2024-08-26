import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0
import "../components"
import "../components/ListItems" as ListItems

ScrollView {
    id: view
    anchors.fill: parent

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: columnLayout.height
        topMargin: units.gu(2)
        bottomMargin: units.gu(4)

        Settings {
            id: mariKitSettingsItem
            category: "marikit"
            fileName: "/home/phablet/.config/lomiri-ui-toolkit/marikit.conf"
            property bool showBottomGestureHint: false
            property bool enableBottomSwipeGesture: true
            property bool enableBackAnimation: false
            property bool enableDelayedBackAnimation: false
            property bool enableHeaderSwipeGesture: true
        }

        ColumnLayout {
            id: columnLayout

            spacing: units.gu(1)
            anchors {
                left: parent.left
                right: parent.right
            }

            Item {
                Layout.fillWidth: true
                height: childrenRect.height

                ListItems.SectionDivider {
                    text: i18n.tr("MariKit")
                    iconName: "ubuntu-sdk-symbolic"
                }
            }
            
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: units.gu(2)
                Layout.rightMargin: units.gu(2)
                Layout.alignment: Qt.AlignLeft| Qt.AlignVCenter
                wrapMode: Text.WordWrap
                font.italic: true
                text: i18n.tr("These settings may only affect unconfined apps. Other apps will use the default values.")
            }

            SettingsSwitch {
                id: enableHeaderSwipeGesture
                Layout.fillWidth: true
                text: "Enable header horizontal swipe gesture"
                onCheckedChanged: mariKitSettingsItem.enableHeaderSwipeGesture = checked
                Binding {
                    target: enableHeaderSwipeGesture
                    property: "checked"
                    value: mariKitSettingsItem.enableHeaderSwipeGesture
                }
            }
            SettingsSwitch {
                id: enableBottomSwipeGesture
                Layout.fillWidth: true
                text: "Enable bottom horizontal swipe gesture"
                onCheckedChanged: mariKitSettingsItem.enableBottomSwipeGesture = checked
                Binding {
                    target: enableBottomSwipeGesture
                    property: "checked"
                    value: mariKitSettingsItem.enableBottomSwipeGesture
                }
            }
            SettingsCheckBox {
                id: showBottomGestureHint
                Layout.fillWidth: true
                text: "Show bottom gesture hint"
                visible: mariKitSettingsItem.enableBottomSwipeGesture
                onCheckedChanged: mariKitSettingsItem.showBottomGestureHint = checked
                Binding {
                    target: showBottomGestureHint
                    property: "checked"
                    value: mariKitSettingsItem.showBottomGestureHint
                }
            }
            SettingsCheckBox {
                id: enableBackAnimation
                Layout.fillWidth: true
                text: "Enable Back animation"
                visible: mariKitSettingsItem.enableBottomSwipeGesture
                onCheckedChanged: mariKitSettingsItem.enableBackAnimation = checked
                Binding {
                    target: enableBackAnimation
                    property: "checked"
                    value: mariKitSettingsItem.enableBackAnimation
                }
            }
            SettingsCheckBox {
                id: enableDelayedBackAnimation
                Layout.fillWidth: true
                text: "Delayed Back animation"
                visible: mariKitSettingsItem.enableBottomSwipeGesture
                onCheckedChanged: mariKitSettingsItem.enableDelayedBackAnimation = checked
                Binding {
                    target: enableDelayedBackAnimation
                    property: "checked"
                    value: mariKitSettingsItem.enableDelayedBackAnimation
                }
            }
        }
    }
}
