import QtQuick
import org.kde.kirigami as Kirigami

/*
 * A bar beneath the clock, in three columns:
 *
 *   date            [icon]           temperature
 *   condition                        high / low
 *
 * Anchored rather than laid out, because the three columns are positioned
 * independently — left edge, centre, right edge — and the icon sits toward
 * the top rather than centred vertically.
 *
 * Width comes from the parent; height derives from `unit` (the card height)
 * so this scales with everything else.
 */
Item {
    id: panel

    property string dateText: ""
    property string condition: ""
    property string iconName: ""
    property string category: ""
    property string temperature: ""
    property string high: ""
    property string low: ""

    property color dimColor: "#9aa1ab"
    property color strongColor: "#f3f3f3"
    property color panelColor: "#000000"
    property real panelAlpha: 0.30
    property string fontFamily: "Fira Sans"
    property real unit: 96

    readonly property real pad: Math.round(unit * 0.08)
    readonly property real iconSize: Math.round(unit * 0.50)

    // How far the icon rises above the panel. 0.12 cancels the column gap
    // above, leaving a 0.05 overlap onto the clock.
    readonly property real iconOverlap: Math.round(unit * 0.17)

    // Space between the left padding and the icon's left edge.
    readonly property real sideWidth: (width - iconSize) / 2 - pad * 1.4

    implicitHeight: Math.round(unit * 0.58)

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.max(2, Math.round(panel.unit * 0.07))
        color: panel.panelColor
        opacity: panel.panelAlpha
    }

    // Top left — day, date, month
    Text {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: panel.pad
        anchors.topMargin: panel.pad
        width: panel.sideWidth
        elide: Text.ElideRight
        text: panel.dateText
        color: panel.dimColor
        font.family: panel.fontFamily
        font.weight: Font.Light
        font.pixelSize: Math.max(1, Math.round(panel.unit * 0.095))
        font.letterSpacing: Math.max(0.3, panel.unit * 0.008)
    }

    // Bottom left — condition
    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: panel.pad
        anchors.bottomMargin: panel.pad
        width: panel.width * 0.5
        elide: Text.ElideRight
        text: panel.condition
        color: panel.strongColor
        font.family: panel.fontFamily
        font.pixelSize: Math.max(1, Math.round(panel.unit * 0.13))
    }

    // Centre, toward the top — condition icon
    AnimatedWeatherIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -panel.iconOverlap
        width: panel.iconSize
        height: width
        iconName: panel.iconName
        category: panel.category
        particleColor: panel.dimColor
        active: hover.containsMouse
    }

    // Top right — current temperature, the largest thing in the panel
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: panel.pad
        anchors.topMargin: Math.round(panel.unit * 0.02)
        text: panel.temperature
        color: panel.strongColor
        font.family: panel.fontFamily
        font.weight: Font.Light
        font.pixelSize: Math.max(1, Math.round(panel.unit * 0.28))
    }

    // Bottom right — today's high and low
    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: panel.pad
        anchors.bottomMargin: panel.pad
        text: panel.high !== "" ? panel.high + " / " + panel.low : ""
        color: panel.dimColor
        font.family: panel.fontFamily
        font.pixelSize: Math.max(1, Math.round(panel.unit * 0.12))
    }
}
