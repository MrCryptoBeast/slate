import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import App

import "." as Ui

GridLayout {
    id: root
    objectName: "hslSimplePickerGridLayout"
    columns: 2
    rowSpacing: 0

    property ImageCanvas canvas
    property Project project

    readonly property real spinBoxFactor: 1000
    readonly property real spinBoxStepSize: 10
    readonly property var spinBoxTextFromValueFunc: function(value) {
        return (value / spinBoxFactor).toFixed(2);
    }
    readonly property int minimumUsefulHeight: hexColourRowLayout.implicitHeight// + pickerRowLayout.Layout.topMargin

    HexColourRowLayout {
        id: hexColourRowLayout
        canvas: root.canvas

        Layout.columnSpan: 2
    }

    RowLayout {
        id: pickerRowLayout
        Layout.columnSpan: 2
        Layout.topMargin: 8
        Layout.bottomMargin: 8
        Layout.alignment: Qt.AlignRight

        HueSlider {
            id: hueSlider
            implicitHeight: saturationLightnessPicker.height

            onHuePicked: canvas[hexColourRowLayout.colourSelector.currentPenPropertyName] = saturationLightnessPicker.color

            function updateOurColour() {
                hueSlider.hue = project && canvas ? canvas[hexColourRowLayout.colourSelector.currentPenPropertyName].hslHue : 0;
            }

            Connections {
                target: canvas
                function onPenForegroundColourChanged() { hueSlider.updateOurColour() }
                function onPenBackgroundColourChanged() { hueSlider.updateOurColour() }
            }

            Connections {
                target: root
                function onProjectChanged() { hueSlider.updateOurColour() }
            }
        }
        SaturationLightnessPicker {
            id: saturationLightnessPicker
            objectName: "saturationLightnessPicker"
            implicitWidth: 156
            implicitHeight: 156
            hue: hueSlider.hue
            alpha: opacitySlider.value

            function updateOurColour() {
                saturationLightnessPicker.color = canvas[hexColourRowLayout.colourSelector.currentPenPropertyName];
            }

            Connections {
                target: canvas
                function onPenForegroundColourChanged() { saturationLightnessPicker.updateOurColour() }
                function onPenBackgroundColourChanged() { saturationLightnessPicker.updateOurColour() }
            }

            Connections {
                target: hexColourRowLayout.colourSelector
                function onCurrentPenNameChanged() { saturationLightnessPicker.updateOurColour() }
            }

            onColorPicked: {
                if (!canvas)
                    return;

                canvas[hexColourRowLayout.colourSelector.currentPenPropertyName] = saturationLightnessPicker.color
            }
        }
    }

    Control {
        Layout.alignment: Qt.AlignHCenter

        ToolTip.visible: hovered
        ToolTip.text: qsTr("Opacity")
        ToolTip.delay: UiConstants.toolTipDelay
        ToolTip.timeout: UiConstants.toolTipTimeout

        background: Image {
            source: "qrc:/images/opacity.png"
        }
    }

    Slider {
        id: opacitySlider
        objectName: "opacitySlider"
        value: canvas ? canvas[hexColourRowLayout.colourSelector.currentPenPropertyName].a : 1
        focusPolicy: Qt.NoFocus

        Layout.fillWidth: true
        Layout.preferredWidth: lightnessRowLayout.implicitWidth

        property bool ignoreChanges: false

        onMoved: {
            if (!canvas)
                return;

            ignoreChanges = true;
            canvas[hexColourRowLayout.colourSelector.currentPenPropertyName].a = opacitySlider.value;
            ignoreChanges = false;
        }

        function updateOurValue() {
            if (ignoreChanges)
                return;

            opacitySlider.value = canvas[hexColourRowLayout.colourSelector.currentPenPropertyName].a;
        }

        Connections {
            target: hexColourRowLayout.colourSelector
            function onCurrentPenNameChanged() {
                opacitySlider.ignoreChanges = true
                opacitySlider.updateOurValue()
                opacitySlider.ignoreChanges = false
            }
        }

        Connections {
            target: canvas
            function onPenForegroundColourChanged() { opacitySlider.updateOurValue() }
            function onPenBackgroundColourChanged() { opacitySlider.updateOurValue() }
        }

        ToolTip {
            parent: opacitySlider.handle
            visible: opacitySlider.hovered || opacitySlider.pressed
            text: (opacitySlider.valueAt(opacitySlider.position) * 100).toFixed(1) + "%"
        }
    }

    Ui.VerticalSeparator {
        topPadding: 0
        bottomPadding: 0

        Layout.columnSpan: 2
        Layout.fillWidth: true
    }

    Control {
        id: lightnessLabel

        contentItem: Label {
            text: "\uf185"
            font.family: "FontAwesome"
            horizontalAlignment: Text.AlignHCenter
        }

        Layout.fillWidth: true

        ToolTip.visible: hovered
        ToolTip.text: qsTr("Lightness")
        ToolTip.delay: UiConstants.toolTipDelay
        ToolTip.timeout: UiConstants.toolTipTimeout
    }

    RowLayout {
        id: lightnessRowLayout

        Button {
            objectName: "darkerButton"
            text: qsTr("-")
            autoRepeat: true
            flat: true
            focusPolicy: Qt.NoFocus

            Layout.maximumWidth: implicitHeight
            Layout.fillWidth: true

            ToolTip.text: qsTr("Darken the %1 colour").arg(hexColourRowLayout.colourSelector.currentPenName)
            ToolTip.visible: hovered
            ToolTip.delay: UiConstants.toolTipDelay
            ToolTip.timeout: UiConstants.toolTipTimeout

            onClicked: saturationLightnessPicker.decreaseLightness()
        }

        Button {
            objectName: "lighterButton"
            text: qsTr("+")
            autoRepeat: true
            flat: true
            focusPolicy: Qt.NoFocus

            Layout.maximumWidth: implicitHeight
            Layout.fillWidth: true

            ToolTip.text: qsTr("Lighten the %1 colour").arg(hexColourRowLayout.colourSelector.currentPenName)
            ToolTip.visible: hovered
            ToolTip.delay: UiConstants.toolTipDelay
            ToolTip.timeout: UiConstants.toolTipTimeout

            onClicked: saturationLightnessPicker.increaseLightness()
        }
    }

    Ui.VerticalSeparator {
        topPadding: 0
        bottomPadding: 0

        Layout.columnSpan: 2
        Layout.fillWidth: true
    }

    Control {
        id: saturationLabel
        implicitWidth: lightnessLabel.implicitWidth
        implicitHeight: lightnessLabel.implicitHeight

        Layout.alignment: Qt.AlignHCenter

        ToolTip.visible: hovered
        ToolTip.text: qsTr("Saturation")
        ToolTip.delay: UiConstants.toolTipDelay
        ToolTip.timeout: UiConstants.toolTipTimeout

        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0; color: Ui.Theme.focusColour }
                GradientStop { position: 1; color: "#ccc" }
            }
        }
    }

    RowLayout {
        Button {
            objectName: "desaturateButton"
            text: qsTr("-")
            autoRepeat: true
            flat: true
            focusPolicy: Qt.NoFocus

            Layout.maximumWidth: implicitHeight
            Layout.fillWidth: true

            //: Desaturate the foreground/background colour.
            ToolTip.text: qsTr("Desaturate the %1 colour").arg(hexColourRowLayout.colourSelector.currentPenName)
            ToolTip.visible: hovered
            ToolTip.delay: UiConstants.toolTipDelay
            ToolTip.timeout: UiConstants.toolTipTimeout

            onClicked: saturationLightnessPicker.decreaseSaturation()
        }

        Button {
            objectName: "saturateButton"
            text: qsTr("+")
            autoRepeat: true
            flat: true
            focusPolicy: Qt.NoFocus

            Layout.maximumWidth: implicitHeight
            Layout.fillWidth: true

            //: Saturate the foreground/background colour.
            ToolTip.text: qsTr("Saturate the %1 colour").arg(hexColourRowLayout.colourSelector.currentPenName)
            ToolTip.visible: hovered
            ToolTip.delay: UiConstants.toolTipDelay
            ToolTip.timeout: UiConstants.toolTipTimeout

            onClicked: saturationLightnessPicker.increaseSaturation()
        }
    }

    Item {
        Layout.columnSpan: 2
        Layout.fillHeight: true
    }
}
