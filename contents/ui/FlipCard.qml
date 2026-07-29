import QtQuick

/*
 * A single split-flap card.
 *
 * Four stacked halves, all clipped to half the card height:
 *   staticTop     shows the INCOMING value  (revealed as the leaf falls away)
 *   staticBottom  shows the OLD value       (until the flip lands)
 *   leafTop       shows the OLD value       hinged at the seam, falls forward
 *   leafBottom    shows the INCOMING value  hinged at the seam, drops into place
 *
 * Phase 1 rotates leafTop from 0 to -90 degrees; phase 2 rotates leafBottom
 * from +90 back to 0. Rotation is about the X axis, so the seam acts as the
 * hinge in both phases.
 */
Item {
    id: card

    property string value: "00"

    // Appearance — tweak these from main.qml or here.
    property real cardRadius: Math.max(3, height * 0.075)
    property string fontFamily: "Fira Sans"
    property int fontWeight: Font.Light
    property color digitColor: "#f3f3f3"
    property color topHighColor: "#43464d"
    property color topLowColor: "#2f3238"
    property color bottomHighColor: "#383b41"
    property color bottomLowColor: "#1c1e22"
    property color seamShadowColor: "#0e1014"
    property color seamHighlightColor: "#ffffff"
    property real seamShadowOpacity: 0.85
    property real seamHighlightOpacity: 0.07

    // How hard a leaf darkens as it turns away. Light cards need much less.
    property real shadeStrength: 0.55
    property int flipDuration: 420

    // Internal state. Deliberately NOT bound to `value` — a binding would
    // update them the instant the time changes and the flip would never run.
    property string displayed: "--"
    property string incoming: "--"
    property real topAngle: 0
    property real bottomAngle: 90
    property bool flipping: false
    property bool ready: false

    Component.onCompleted: {
        displayed = value;
        incoming = value;
        ready = true;
    }

    onValueChanged: {
        if (!ready || value === displayed) {
            return;
        }
        if (flip.running) {
            flip.complete();   // land the previous flip before starting the next
        }
        incoming = value;
        flip.start();
    }

    // One clipped half of a card face. `section` 0 = top, 1 = bottom.
    component Half: Item {
        id: h

        property int section: 0
        property string label: "00"
        property real shade: 0

        width: card.width
        height: card.height / 2
        clip: true

        // Full-height face, shifted up for the bottom half so the digit
        // lands in the same place in both halves and lines up across the seam.
        Rectangle {
            width: card.width
            height: card.height
            y: h.section === 0 ? 0 : -card.height / 2
            radius: card.cardRadius

            // Each half carries its own gradient so there is a tonal step at
            // the seam. Stops outside the visible range are clipped away.
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: h.section === 0 ? card.topHighColor : card.bottomHighColor
                }
                GradientStop {
                    position: 0.5
                    color: h.section === 0 ? card.topLowColor : card.bottomHighColor
                }
                GradientStop {
                    position: 1.0
                    color: h.section === 0 ? card.topLowColor : card.bottomLowColor
                }
            }

            Text {
                anchors.centerIn: parent
                text: h.label
                color: card.digitColor
                font.family: card.fontFamily
                font.weight: card.fontWeight
                font.pixelSize: Math.max(1, Math.round(card.height * 0.68))
            }

            // Seam: a dark hairline closing the top half, a faint highlight
            // opening the bottom half.
            Rectangle {
                width: parent.width
                height: 1
                y: h.section === 0 ? card.height / 2 - 1 : card.height / 2
                color: h.section === 0 ? card.seamShadowColor : card.seamHighlightColor
                opacity: h.section === 0 ? card.seamShadowOpacity : card.seamHighlightOpacity
            }
        }

        // Darkens the leaf as it turns away from the light. This sells the
        // 3D far more convincingly than the rotation alone does.
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: h.shade
        }
    }

    Half {
        id: staticTop
        section: 0
        label: card.incoming
        y: 0
    }

    Half {
        id: staticBottom
        section: 1
        label: card.displayed
        y: card.height / 2
    }

    Half {
        id: leafTop
        section: 0
        label: card.displayed
        y: 0
        visible: card.flipping && card.topAngle > -90
        shade: Math.min(card.shadeStrength,
                        Math.abs(card.topAngle) / 90 * card.shadeStrength)
        transform: Rotation {
            origin.x: card.width / 2
            origin.y: card.height / 2     // the seam — leafTop's bottom edge
            axis { x: 1; y: 0; z: 0 }
            angle: card.topAngle
        }
    }

    Half {
        id: leafBottom
        section: 1
        label: card.incoming
        y: card.height / 2
        visible: card.flipping && card.bottomAngle < 90
        shade: Math.min(card.shadeStrength,
                        card.bottomAngle / 90 * card.shadeStrength)
        transform: Rotation {
            origin.x: card.width / 2
            origin.y: 0                   // the seam — leafBottom's top edge
            axis { x: 1; y: 0; z: 0 }
            angle: card.bottomAngle
        }
    }

    SequentialAnimation {
        id: flip

        ScriptAction {
            script: {
                card.flipping = true;
                card.topAngle = 0;
                card.bottomAngle = 90;
            }
        }
        NumberAnimation {
            target: card
            property: "topAngle"
            from: 0
            to: -90
            duration: card.flipDuration / 2
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: card
            property: "bottomAngle"
            from: 90
            to: 0
            duration: card.flipDuration / 2
            easing.type: Easing.OutQuad
        }
        ScriptAction {
            script: {
                card.displayed = card.incoming;
                card.flipping = false;
            }
        }
    }
}
