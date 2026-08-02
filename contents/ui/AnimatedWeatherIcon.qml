import QtQuick
import org.kde.kirigami as Kirigami

/*
 * The condition icon, with motion that matches the weather while `active`.
 *
 *   clear   slow rotation of the sun
 *   clouds  lateral drift
 *   rain    falling streaks behind the icon
 *   snow    slower, larger flakes drifting behind
 *   storm   a double flash on a long cycle
 *   fog     opacity breathing
 *
 * Everything is driven off `active`, so nothing animates — and nothing costs
 * anything — until the pointer is over the panel.
 */
Item {
    id: root

    property string iconName: ""
    property string category: ""
    property bool active: false
    property color particleColor: "#9aa1ab"

    readonly property bool raining: category === "rain"
    readonly property bool snowing: category === "snow"
    readonly property int particleCount: (raining || snowing) ? 6 : 0

    // Particles sit behind the icon so it stays crisp.
    Repeater {
        model: root.particleCount

        Rectangle {
            id: drop
            readonly property bool flake: root.snowing

            width: flake ? root.width * 0.09 : root.width * 0.03
            height: flake ? width : root.height * 0.18
            radius: width / 2
            color: root.particleColor
            opacity: 0
            x: root.width * (0.1 + 0.8 * (index / Math.max(1, root.particleCount - 1)))

            SequentialAnimation {
                running: root.active
                loops: Animation.Infinite

                PauseAnimation { duration: index * (drop.flake ? 280 : 140) }

                ParallelAnimation {
                    NumberAnimation {
                        target: drop
                        property: "y"
                        from: -root.height * 0.12
                        to: root.height * 1.05
                        duration: drop.flake ? 2800 : 950
                        easing.type: drop.flake ? Easing.InOutSine : Easing.InQuad
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: drop; property: "opacity"
                            from: 0; to: 0.7; duration: 160
                        }
                        PauseAnimation { duration: drop.flake ? 2200 : 500 }
                        NumberAnimation {
                            target: drop; property: "opacity"
                            to: 0; duration: 260
                        }
                    }
                }
            }
        }
    }

    // Not anchored: x, rotation and opacity are animated, and anchors would
    // fight the x binding.
    Item {
        id: holder
        width: root.width
        height: root.height

        Kirigami.Icon {
            anchors.fill: parent
            source: root.iconName
            visible: root.iconName !== ""
        }
    }

    RotationAnimation {
        target: holder
        running: root.active && root.category === "clear"
        from: 0
        to: 360
        duration: 9000
        loops: Animation.Infinite
    }

    SequentialAnimation {
        running: root.active && root.category === "clouds"
        loops: Animation.Infinite
        NumberAnimation {
            target: holder; property: "x"
            to: root.width * 0.07; duration: 1500; easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: holder; property: "x"
            to: -root.width * 0.07; duration: 3000; easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: holder; property: "x"
            to: 0; duration: 1500; easing.type: Easing.InOutSine
        }
    }

    SequentialAnimation {
        running: root.active && root.category === "fog"
        loops: Animation.Infinite
        NumberAnimation {
            target: holder; property: "opacity"
            to: 0.35; duration: 1300; easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: holder; property: "opacity"
            to: 1.0; duration: 1300; easing.type: Easing.InOutSine
        }
    }

    SequentialAnimation {
        running: root.active && root.category === "storm"
        loops: Animation.Infinite
        NumberAnimation { target: holder; property: "opacity"; to: 0.2; duration: 70 }
        NumberAnimation { target: holder; property: "opacity"; to: 1.0; duration: 90 }
        PauseAnimation { duration: 110 }
        NumberAnimation { target: holder; property: "opacity"; to: 0.45; duration: 60 }
        NumberAnimation { target: holder; property: "opacity"; to: 1.0; duration: 120 }
        PauseAnimation { duration: 1800 }
    }

    // Leaving the panel mid-animation would otherwise strand the icon
    // rotated, offset or half-transparent.
    onActiveChanged: {
        if (!active) {
            holder.rotation = 0;
            holder.x = 0;
            holder.opacity = 1;
        }
    }
}
