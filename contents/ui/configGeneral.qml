import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_use24Hour: use24Box.checked
    property alias cfg_showDate: dateBox.checked
    property alias cfg_secondsStyle: secondsCombo.currentIndex
    property alias cfg_themeMode: themeCombo.currentIndex
    property alias cfg_fontFamily: fontField.text

    QQC2.ComboBox {
        id: themeCombo
        Kirigami.FormData.label: i18n("Theme:")
        model: [i18n("Dark"), i18n("Light"), i18n("Follow colour scheme")]
    }

    QQC2.ComboBox {
        id: secondsCombo
        Kirigami.FormData.label: i18n("Seconds:")
        model: [i18n("Hidden"), i18n("Sweeping bar"), i18n("Flip card")]
    }

    QQC2.CheckBox {
        id: use24Box
        Kirigami.FormData.label: i18n("24-hour clock:")
    }

    QQC2.CheckBox {
        id: dateBox
        Kirigami.FormData.label: i18n("Show date:")
    }

    QQC2.TextField {
        id: fontField
        Kirigami.FormData.label: i18n("Font family:")
    }
}
