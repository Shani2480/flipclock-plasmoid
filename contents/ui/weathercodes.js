.pragma library

/*
 * Open-Meteo reports conditions as WMO weather codes. Map them to a short
 * label and a Breeze icon name.
 *
 * The third element is an animation category, used to pick the hover motion.
 * Night variants exist for clear / few-clouds / clouds only; overcast and
 * everything wetter look the same after dark, so they have no -night form.
 */
function lookup(code, isDay) {
    var n = isDay ? "" : "-night";

    switch (code) {
    case 0:  return ["Clear",              "weather-clear" + n, "clear"];
    case 1:  return ["Mainly clear",       "weather-few-clouds" + n, "clouds"];
    case 2:  return ["Partly cloudy",      "weather-clouds" + n, "clouds"];
    case 3:  return ["Overcast",           "weather-many-clouds", "clouds"];

    case 45:
    case 48: return ["Fog",                "weather-fog", "fog"];

    case 51:
    case 53:
    case 55: return ["Drizzle",            "weather-showers-scattered", "rain"];
    case 56:
    case 57: return ["Freezing drizzle",   "weather-freezing-rain", "rain"];

    case 61:
    case 63: return ["Rain",               "weather-showers", "rain"];
    case 65: return ["Heavy rain",         "weather-showers", "rain"];
    case 66:
    case 67: return ["Freezing rain",      "weather-freezing-rain", "rain"];

    case 71:
    case 73: return ["Snow",               "weather-snow", "snow"];
    case 75: return ["Heavy snow",         "weather-snow", "snow"];
    case 77: return ["Snow grains",        "weather-snow", "snow"];

    case 80:
    case 81: return ["Rain showers",       "weather-showers-scattered", "rain"];
    case 82: return ["Heavy showers",      "weather-showers", "rain"];
    case 85:
    case 86: return ["Snow showers",       "weather-snow", "snow"];

    case 95: return ["Thunderstorm",       "weather-storm", "storm"];
    case 96:
    case 99: return ["Thunderstorm, hail", "weather-storm", "storm"];
    }

    return ["", "weather-none-available", ""];
}
