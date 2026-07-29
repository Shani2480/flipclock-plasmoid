import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property bool use24Hour: Plasmoid.configuration.use24Hour
    readonly property bool showDate: Plasmoid.configuration.showDate
    readonly property string fontFamily: Plasmoid.configuration.fontFamily

    // 0 = none, 1 = sweeping bar, 2 = third flip card
    readonly property int secondsStyle: Plasmoid.configuration.secondsStyle
    // 0 = dark, 1 = light, 2 = follow the Plasma colour scheme
    readonly property int themeMode: Plasmoid.configuration.themeMode

    readonly property bool lightMode: themeMode === 1
        || (themeMode === 2 && Kirigami.Theme.backgroundColor.hslLightness > 0.5)

    readonly property color cTopHigh:   lightMode ? "#fcfcfc" : "#43464d"
    readonly property color cTopLow:    lightMode ? "#e4e4e4" : "#2f3238"
    readonly property color cBotHigh:   lightMode ? "#f1f1f1" : "#383b41"
    readonly property color cBotLow:    lightMode ? "#cdcdcd" : "#1c1e22"
    readonly property color cDigit:     lightMode ? "#2b2b2b" : "#f3f3f3"

    // Dark digits on a light card need more weight to hold; light on dark
    // needs less. Same reason the panel snippets stepped up for light panels.
    readonly property int digitWeight:  lightMode ? Font.DemiBold : Font.Light
    readonly property color cLabel:     lightMode ? "#6b7280" : "#9aa1ab"
    readonly property color cAccent:    lightMode ? "#a8823c" : "#d4b06a"
    readonly property color cSeamDark:  lightMode ? "#8a8f98" : "#0e1014"
    readonly property real seamDarkOpacity:  lightMode ? 0.40 : 0.85
    readonly property real seamLightOpacity: lightMode ? 0.85 : 0.07
    readonly property real shadeStrength:    lightMode ? 0.28 : 0.55

    property date now: new Date()

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground


    // The bar needs sub-second resolution; the cards do not.
    Timer {
        interval: root.secondsStyle === 1 ? 100
                : root.secondsStyle === 2 ? 200
                : 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    function pad(n) {
        return n < 10 ? "0" + n : String(n);
    }

    readonly property string hhText: {
        var h = now.getHours();
        if (!use24Hour) {
            h = (h % 12) || 12;
        }
        return pad(h);
    }
    readonly property string mmText: pad(now.getMinutes())
    readonly property string ssText: pad(now.getSeconds())
    readonly property real secondFraction:
        (now.getSeconds() * 1000 + now.getMilliseconds()) / 60000

    fullRepresentation: Item {
        id: face

        readonly property bool horiz: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
        readonly property bool vert: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property bool inPanel: horiz || vert

        // A date line in a 44px panel would crush the cards to nothing.
        readonly property bool wantDate: root.showDate && !inPanel
        readonly property bool wantBar: root.secondsStyle === 1
        readonly property bool wantAmPm: !root.use24Hour
        readonly property int cardCount: root.secondsStyle === 2 ? 3 : 2

        readonly property int pad: inPanel
            ? Math.max(1, Math.round((horiz ? height : width) * 0.06)) : 0

        // The composition measured in multiples of one card height. A vertical
        // panel stacks the cards, so the two axes swap roles.
        readonly property real wUnits: vert
            ? 0.76
            : cardCount * 0.76 + (cardCount - 1) * 0.09 + (wantAmPm ? 0.42 : 0)
        readonly property real hUnits: vert
            ? cardCount + (cardCount - 1) * 0.09 + (wantBar ? 0.20 : 0)
            : 1.0 + (wantDate ? 0.34 : 0) + (wantBar ? 0.20 : 0)

        // In a panel only one axis is ours to choose; on the desktop, both.
        readonly property int cardH: {
            var h = Math.max(1, height - 2 * pad);
            var w = Math.max(1, width - 2 * pad);
            if (horiz) {
                return Math.max(10, Math.floor(h / hUnits));
            }
            if (vert) {
                return Math.max(10, Math.floor(w / wUnits));
            }
            return Math.max(20, Math.floor(Math.min(w / wUnits, h / hUnits)));
        }
        readonly property int cardW: Math.round(cardH * 0.76)
        readonly property int gap: Math.max(2, Math.round(cardH * 0.09))

        readonly property int contentW: Math.ceil(cardH * wUnits) + 2 * pad
        readonly property int contentH: Math.ceil(cardH * hUnits) + 2 * pad

        // Pinning min = max = preferred on the free axis is what stops the
        // panel handing us far more width than the content needs.
        Layout.minimumWidth:   horiz ? contentW : Kirigami.Units.gridUnit * 3
        Layout.maximumWidth:   horiz ? contentW : Number.POSITIVE_INFINITY
        Layout.preferredWidth: horiz ? contentW : Kirigami.Units.gridUnit * 16

        Layout.minimumHeight:   vert ? contentH : Kirigami.Units.gridUnit * 2
        Layout.maximumHeight:   vert ? contentH : Number.POSITIVE_INFINITY
        Layout.preferredHeight: vert ? contentH : Kirigami.Units.gridUnit * 9

        Accessible.role: Accessible.StaticText
        Accessible.name: root.now.toLocaleTimeString(Qt.locale(), Locale.LongFormat)
        Accessible.description: root.now.toLocaleDateString(Qt.locale(), Locale.LongFormat)

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            mainText: root.now.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
            subText: root.now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
        }

        Column {
            anchors.centerIn: parent
            spacing: face.inPanel
                ? Math.max(2, Math.round(face.cardH * 0.08))
                : Math.round(face.cardH * 0.12)

            // Plain positioners, not Layouts: they skip invisible children
            // without leaving a gap, which is what we want as options toggle.
            Grid {
                id: cards
                anchors.horizontalCenter: parent.horizontalCenter
                columns: face.vert ? 1 : 4
                spacing: face.gap
                verticalItemAlignment: Grid.AlignVCenter

                Repeater {
                    model: 3
                    FlipCard {
                        visible: index < 2 || root.secondsStyle === 2
                        width: face.cardW
                        height: face.cardH
                        value: index === 0 ? root.hhText
                             : index === 1 ? root.mmText
                             : root.ssText
                        fontFamily: root.fontFamily
                        fontWeight: root.digitWeight
                        digitColor: root.cDigit
                        topHighColor: root.cTopHigh
                        topLowColor: root.cTopLow
                        bottomHighColor: root.cBotHigh
                        bottomLowColor: root.cBotLow
                        seamShadowColor: root.cSeamDark
                        seamShadowOpacity: root.seamDarkOpacity
                        seamHighlightOpacity: root.seamLightOpacity
                        shadeStrength: root.shadeStrength
                    }
                }

                Text {
                    visible: face.wantAmPm
                    text: root.now.getHours() < 12 ? "AM" : "PM"
                    color: root.cLabel
                    font.family: root.fontFamily
                    font.weight: Font.Light
                    font.pixelSize: Math.max(1, Math.round(face.cardH * 0.17))
                    font.letterSpacing: 1.5
                }
            }

            // Seconds as a brass hairline sweeping across the minute.
            Item {
                visible: face.wantBar
                anchors.horizontalCenter: parent.horizontalCenter
                width: cards.width
                height: Math.max(2, Math.round(face.cardH * 0.04))

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(root.cLabel.r, root.cLabel.g, root.cLabel.b, 0.22)
                }
                Rectangle {
                    width: parent.width * root.secondFraction
                    height: parent.height
                    radius: height / 2
                    color: root.cAccent
                }
            }

            Text {
                visible: face.wantDate
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.now.toLocaleDateString(Qt.locale(), "dddd d MMMM").toUpperCase()
                color: root.cLabel
                font.family: root.fontFamily
                font.weight: Font.Light
                font.pixelSize: Math.max(1, Math.round(face.cardH * 0.14))
                font.letterSpacing: Math.max(1, face.cardH * 0.035)
            }
        }
    }
}
