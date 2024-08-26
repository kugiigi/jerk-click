import QtQuick 2.4
import Lomiri.Components 1.3
import "../components/ListItems" as ListItems
import "../components"

ScrollView {
    id: rootItem
    anchors.fill: parent

    InstallerActionsItem {
        id: actionsItem

        package_id: ""
        packageName: ""
        component_id: ""
        componentName: ""
        fileName: ""
        hasRestart: false
    }

    Column {
        width: rootItem.width

        QtObject {
            id: internal

            property var componentsWithRestart

            Component.onCompleted: {
                let _array = mainView.componentList.slice()
                // Filter to only with restart and rmeove duplicates
                componentsWithRestart = _array.filter((value, index, self) =>
                  index === self.findIndex((t) => (
                    t.name === value.name && t.hasRestart === true
                  ))
                )

                restartRepeater.model = componentsWithRestart
            }

            function resetComponent(_componentId, _componentName) {
                actionsItem.component_id = _componentId
                actionsItem.componentName = _componentName
                actionsItem.askToReset()
            }

            function restartComponent(_componentId, _componentName) {
                actionsItem.component_id = _componentId
                actionsItem.componentName = _componentName
                actionsItem.askToRestart()
            }
        }
        
        ListItems.SectionDivider {
            iconName: "reset"
            text: i18n.tr("Reset Components")
        }
        
        Repeater {
            model: mainView.componentList
            delegate: ListItems.Control {
                title.text: modelData.name
                onClicked: internal.resetComponent(modelData.component_id, modelData.name)
            }
        }

        ListItems.SectionDivider {
            iconName: "reload_page"
            text: i18n.tr("Restart Components")
        }

        Repeater {
            id: restartRepeater
            delegate: ListItems.Control {
                title.text: modelData.name
                onClicked: internal.restartComponent(modelData.component_id, modelData.name)
            }
        }

        ListItems.SectionDivider {
            iconName: "preferences-system-updates-symbolic"
            text: i18n.tr("OTA Updates")
        }

        ListItems.Control {
            title.text: i18n.tr("Block")
            iconName: "cancel"
            onClicked: actionsItem.askToBlockOTA()
        }

        ListItems.Control {
            title.text: i18n.tr("Unblock")
            iconName: "tick"
            onClicked: actionsItem.askToUnblockOTA()
        }
    }
}
