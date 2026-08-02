#!/usr/bin/env bash
# Build a distributable .plasmoid from this repo.
#
# Verifies every required file exists BEFORE zipping, and verifies the
# mainscript survived into the archive afterwards. An earlier version used
# `zip -q`, which silently swallowed "name not matched" warnings and happily
# produced packages with no contents/ directory. Those install without error
# and then fail at load with "File name empty! / Invalid empty URL".
set -euo pipefail
cd "$(dirname "$(realpath "$0")")"

REQUIRED=(
    metadata.json
    LICENSE
    README.md
    contents/ui/main.qml
    contents/ui/FlipCard.qml
    contents/ui/configGeneral.qml
    contents/ui/configWeather.qml
    contents/ui/WeatherPanel.qml
    contents/ui/AnimatedWeatherIcon.qml
    contents/ui/weathercodes.js
    contents/config/main.xml
    contents/config/config.qml
)

missing=0
for f in "${REQUIRED[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "MISSING: $f" >&2
        missing=1
    fi
done

if (( missing )); then
    echo >&2
    echo "Refusing to build an incomplete package." >&2
    exit 1
fi

VERSION=$(python3 -c "import json;print(json.load(open('metadata.json'))['KPlugin']['Version'])")
OUT="flipclock-${VERSION}.plasmoid"

rm -f "$OUT"
zip -r "$OUT" metadata.json contents LICENSE README.md >/dev/null

# The loader needs this exact path; prove it is in there.
# Capture the listing first: piping straight into `grep -q` lets grep exit on
# match, SIGPIPEs unzip, and `pipefail` then reports the whole pipeline as
# failed — a false "missing" that depends on buffering timing.
listing=$(unzip -l "$OUT")
if ! printf '%s\n' "$listing" | grep -q 'contents/ui/main.qml'; then
    echo "Archive is missing contents/ui/main.qml — aborting." >&2
    rm -f "$OUT"
    exit 1
fi

echo "Built $OUT"
printf '%s\n' "$listing"
