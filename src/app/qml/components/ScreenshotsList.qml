import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: rootItem

    readonly property bool isZoomed: state == "zoom"
    property alias model: screenshotsView.model
    property string path

    visible: screenshotsView.count > 0

    function switchToZoomed() {
        state = "zoom"
    }

    function switchToNormal() {
        state = "normal"
    }

    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: screenshotsView
                oneAtATime: false
                height: units.gu(30)
                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.NoHighlightRange
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            PropertyChanges {
                target: viewShadowsContainer
                visible: true
            }
            PropertyChanges {
                target: swipeArea
                enabled: false
            }
            PropertyChanges {
                target: controlsOverlay
                noCloseButton: true
            }
            ParentChange {
                target: viewContainer
                parent: rootItem
            }
            StateChangeScript {
                script: {
                    mainView.overlayContainer.hide()
                    controlsOverlay.show()
                }
            }
        }
        , State {
            name: "zoom"
            PropertyChanges {
                target: screenshotsView
                oneAtATime: true
                height: parent.height
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange // Select current item in view
                leftMargin: 0
                rightMargin: 0
            }
            PropertyChanges {
                target: viewShadowsContainer
                visible: false
            }
            PropertyChanges {
                target: swipeArea
                enabled: true
            }
            PropertyChanges {
                target: controlsOverlay
                noCloseButton: false
            }
            ParentChange {
                target: viewContainer
                parent: mainView.overlayContainer
            }
            StateChangeScript {
                script: {
                    mainView.overlayContainer.show()
                    controlsOverlay.show()
                }
            }
        }
    ]

    transitions: Transition {
        to: "zoom"
        SequentialAnimation {
            // TODO: Disable for now since scrolling to currentindex is very glitchy
            /*
            ParentAnimation {
                LomiriNumberAnimation {
                    target: screenshotsView
                    properties: "width, height"
                }
            }
            */
            ScriptAction {
                script: delayPositioning.restart()
            }
        }
    }
    
    Timer {
        id: delayPositioning
        interval: 1
        onTriggered: screenshotsView.positionViewAtIndex(screenshotsView.indexToZoom, ListView.SnapPosition)
    }

    Item {
        id: viewContainer
        
        anchors.fill: parent

        ListView {
            id: screenshotsView

            property bool oneAtATime: false
            property int indexToZoom: -1

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            clip: true
            height: units.gu(30)
            spacing: units.gu(1)
            currentIndex: 0
            orientation: ListView.Horizontal
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.OvershootBounds
            cacheBuffer: units.gu(1000)

            onMovingChanged: if (moving && !rootItem.isZoomed) controlsOverlay.show()

            Behavior on opacity { LomiriNumberAnimation {} }
            Behavior on scale { LomiriNumberAnimation {} }

            delegate: LomiriShape {
                id: screenshotShape

                height: ListView.view.oneAtATime ? ListView.view.height : parent.height
                width: ListView.view.oneAtATime ? ListView.view.width : screenshot.implicitWidth * height / screenshot.implicitHeight
                aspect: LomiriShape.Flat
                sourceFillMode: LomiriShape.PreserveAspectFit
                source: Image {
                    id: screenshot
                    asynchronous: true
                    source: Qt.resolvedUrl("../screenshots/" + rootItem.path + "/" + modelData)
                    smooth: false
                    sourceSize.height: screenshotsView.height
                }

                AbstractButton {
                    id: screenShotButton

                    anchors.fill: parent
                    onClicked: {
                        if (!rootItem.isZoomed) {
                            screenshotsView.currentIndex = index
                            screenshotsView.indexToZoom = index
                            rootItem.switchToZoomed()
                        } else {
                            controlsOverlay.toggleShow()
                        }
                        
                    }
                }
            }
        }
        
        Item {
            id: controlsOverlay

            readonly property bool fullyShown: opacity === 1
            readonly property Timer toggleTimer:  Timer {
                interval: 2000
                onTriggered: controlsOverlay.hide()
            }
            property bool noCloseButton: true

            opacity: 0
            anchors.fill: parent

            function toggleShow() {
                opacity = opacity == 0 ? 1 : 0
            }

            function show() {
                opacity = 1
            }

            function hide() {
                opacity = 0
            }

            Component.onCompleted: toggleTimer.restart()

            onFullyShownChanged: {
                if (fullyShown) {
                    toggleTimer.restart()
                }
            }

            Behavior on opacity { LomiriNumberAnimation{} }

            ActionButton {
                iconName: "close"
                width: units.gu(6)
                height: width
                visible: !controlsOverlay.noCloseButton
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: units.gu(2)
                }

                onClicked: rootItem.switchToNormal()
            }
            ActionButton {
                iconName: "previous"
                width: units.gu(6)
                height: width
                visible: screenshotsView.currentIndex > 0
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    margins: units.gu(2)
                }

                onClicked: {
                    screenshotsView.decrementCurrentIndex()
                    screenshotsView.positionViewAtIndex(screenshotsView.currentIndex, ListView.Center)
                    controlsOverlay.toggleTimer.restart()
                }
            }
            ActionButton {
                iconName: "next"
                width: units.gu(6)
                height: width
                visible: screenshotsView.currentIndex < screenshotsView.count - 1
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    margins: units.gu(2)
                }

                onClicked: {
                    screenshotsView.incrementCurrentIndex()
                    screenshotsView.positionViewAtIndex(screenshotsView.currentIndex, ListView.Center)
                    controlsOverlay.toggleTimer.restart()
                }
            }
        }

        SwipeArea {
            id: swipeArea
            
            readonly property real threshold: units.gu(15)
            readonly property bool readyToTrigger: distance >= threshold

            enabled: false
            anchors.fill: parent
            direction: SwipeArea.Upwards
            immediateRecognition: false

            onReadyToTriggerChanged: Haptics.play()
            onDraggingChanged: {
                if (!dragging) {
                    if (distance >= threshold) {
                        rootItem.switchToNormal()
                    }

                    screenshotsView.opacity = 1
                    screenshotsView.scale = 1
                }
            }

            onDistanceChanged: {
                if (dragging) {
                    let _newScale = 1
                    let _newOpacity = 1

                    if (readyToTrigger) {
                        _newScale = 0.6
                        _newOpacity = 0.4
                    } else if (distance >= 0) {
                        _newScale = 1 - 0.4 * distance / threshold
                        _newOpacity = 1 - 0.6 * distance / threshold
                    }

                    screenshotsView.scale = _newScale
                    screenshotsView.opacity = _newOpacity
                }
            }
        }
    }

    Item {
        id: viewShadowsContainer

        z: viewContainer.z + 1
        anchors {
            fill: parent
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
        }

        ListViewEndShadow {
            view: screenshotsView
            edge: Qt.LeftEdge
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
        }

        ListViewEndShadow {
            view: screenshotsView
            edge: Qt.RightEdge
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
        }
    }
}
