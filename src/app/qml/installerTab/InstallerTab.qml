import QtQuick 2.12
import Lomiri.Components 1.3
import "../components/ListItems" as ListItems

ScrollView {
    id: view
    anchors.fill: parent

    Column {
        width: view.width

        ListItems.SectionDivider {
            text: i18n.tr("Bluetooth")
            iconName: "bluetooth-active"
        }

        ListItems.Page {
            text: i18n.tr("BREDR-FAST")
            summary.text: i18n.tr("Changes controller mode from 'auto' to 'bredr' and enables 'FastConnectable'.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "bluetooth_conf", "package_id": "bredr_fast", "pageTitle": text }
        }
        
        ListItems.SectionDivider {
            text: i18n.tr("Lomiri")
            iconName: "preferences-desktop-launcher-symbolic"
        }

        ListItems.Page {
            text: i18n.tr("Lomiri Plus Essentials")
            summary.text: i18n.tr("Minimal Lomiri Plus that only includes essential hacks such as notch & rounded corner support.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "lomiri", "package_id": "lomiri_plus_essentials", "pageTitle": text }
        }

        ListItems.Page {
            text: i18n.tr("Lomiri Plus")
            summary.text: i18n.tr("Kugi's playground for Lomiri experiments.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "lomiri", "package_id": "lomiri_plus", "pageTitle": text }
        }

        ListItems.SectionDivider {
            text: i18n.tr("On-Screen Keyboard")
            iconName: "input-keyboard-symbolic"
        }

        ListItems.Page {
            text: i18n.tr("Malakiboard")
            summary.text: i18n.tr("Kugi's playground for the on-screen keyboard.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "maliit-keyboard", "package_id": "malakiboard", "pageTitle": text }
        }

        ListItems.Page {
            text: i18n.tr("Malakiboard Layouts")
            summary.text: i18n.tr("Companion package of Malakiboard")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "maliit-keyboard-layouts", "package_id": "malakiboard_layouts", "pageTitle": text }
        }

        ListItems.SectionDivider {
            text: i18n.tr("System Settings")
            iconName: "settings"
        }

        ListItems.Page {
            text: i18n.tr("Show Launcher Page")
            summary.text: i18n.tr("Hack in the settings app to always show the Desktop & Launcher page.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "system-settings", "package_id": "settings_show_launcher", "pageTitle": text }
        }

        ListItems.SectionDivider {
            text: i18n.tr("Lomiri Toolkit")
            iconName: "ubuntu-sdk-symbolic"
        }

        ListItems.Page {
            text: i18n.tr("MariKit")
            summary.text: i18n.tr("Adds and modifies UI and features in apps that use UT's standard toolkit.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "uitk", "package_id": "marikit", "pageTitle": text }
        }

        ListItems.SectionDivider {
            text: i18n.tr("Web App Container")
            iconName: "stock_website"
        }

        ListItems.Page {
            text: i18n.tr("Sapot Container")
            summary.text: i18n.tr("Makes web apps look and work like Sapot Browser.")
            summary.maximumLineCount: Number.MAX_VALUE
            pageUrl: Qt.resolvedUrl("PackagePage.qml")
            pushProperties: { "component_id": "webcontainer", "package_id": "sapot_container", "pageTitle": text }
        }
    }
}
