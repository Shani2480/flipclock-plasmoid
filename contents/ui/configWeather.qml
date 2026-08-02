import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showWeather: enableBox.checked
    property alias cfg_weatherFahrenheit: fahrenheitBox.checked

    // Not aliases: these are written by the search results, not by a control.
    property string cfg_weatherPlace: ""
    property double cfg_weatherLatitude: 0
    property double cfg_weatherLongitude: 0

    QQC2.CheckBox {
        id: enableBox
        Kirigami.FormData.label: i18n("Show weather:")
    }

    QQC2.CheckBox {
        id: fahrenheitBox
        Kirigami.FormData.label: i18n("Fahrenheit:")
        enabled: enableBox.checked
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Find location:")
        enabled: enableBox.checked

        QQC2.TextField {
            id: searchField
            Layout.preferredWidth: Kirigami.Units.gridUnit * 12
            placeholderText: i18n("City name")
            onAccepted: page.search()
        }

        QQC2.Button {
            text: i18n("Search")
            icon.name: "search"
            onClicked: page.search()
        }
    }

    QQC2.ComboBox {
        id: resultsBox
        Kirigami.FormData.label: i18n("Results:")
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        enabled: enableBox.checked && resultsModel.count > 0
        model: resultsModel
        textRole: "label"
        onActivated: {
            var r = resultsModel.get(currentIndex);
            page.cfg_weatherPlace = r.place;
            page.cfg_weatherLatitude = r.lat;
            page.cfg_weatherLongitude = r.lon;
        }
    }

    QQC2.Label {
        Kirigami.FormData.label: i18n("Selected:")
        text: page.cfg_weatherPlace !== ""
            ? page.cfg_weatherPlace + "  (" + page.cfg_weatherLatitude.toFixed(2)
              + ", " + page.cfg_weatherLongitude.toFixed(2) + ")"
            : i18n("none")
        opacity: page.cfg_weatherPlace !== "" ? 1 : 0.6
    }

    QQC2.Label {
        text: i18n("Weather data by Open-Meteo.com")
        font: Kirigami.Theme.smallFont
        opacity: 0.6
    }

    ListModel { id: resultsModel }

    function search() {
        var name = searchField.text.trim();
        if (name === "") {
            return;
        }
        resultsModel.clear();

        var url = "https://geocoding-api.open-meteo.com/v1/search"
                + "?name=" + encodeURIComponent(name)
                + "&count=8&language=en&format=json";

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            if (xhr.status !== 200) {
                return;
            }
            try {
                var results = JSON.parse(xhr.responseText).results || [];
                for (var i = 0; i < results.length; i++) {
                    var r = results[i];
                    var region = r.admin1 ? ", " + r.admin1 : "";
                    var country = r.country ? ", " + r.country : "";
                    resultsModel.append({
                        label: r.name + region + country,
                        place: r.name,
                        lat: r.latitude,
                        lon: r.longitude
                    });
                }
                if (resultsModel.count > 0) {
                    resultsBox.currentIndex = 0;
                    resultsBox.activated(0);
                }
            } catch (e) {
                // Malformed response: leave the list empty.
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }
}
