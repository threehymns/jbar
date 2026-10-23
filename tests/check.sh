#!/usr/bin/env bash
#
# check.sh — the gate of the tree.
#
# Every test of the headless modules runs, and every QML file is linted with
# qmllint. Both have to pass before a change is committed. The rest of the
# checks keep the hygiene of the project: no private Quickshell module is
# imported, config.example.json documents every setting, and the README
# lists the runtime requirements and the live config path.
#
# Run it from any directory:
#
#     ./tests/check.sh
#
# A different Qt installation can be used with QMLTESTRUNNER, QMLLINT and
# QML_IMPORT_PATH.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The checks and the lint output are relative to the root, so the script
# reads the same no matter where it is started from.
cd "$root"

qmltestrunner="${QMLTESTRUNNER:-}"
if [[ -z "$qmltestrunner" ]]; then
    # The Qt 6 tools come first: /usr/bin/qmltestrunner may still be the Qt 5
    # one when both major versions are installed.
    if [[ -x /usr/lib/qt6/bin/qmltestrunner ]]; then
        qmltestrunner=/usr/lib/qt6/bin/qmltestrunner
    elif command -v qmltestrunner >/dev/null 2>&1; then
        qmltestrunner="$(command -v qmltestrunner)"
    else
        echo "check: qmltestrunner was not found" >&2
        exit 1
    fi
fi

qmllint="${QMLLINT:-}"
if [[ -z "$qmllint" ]]; then
    if [[ -x /usr/lib/qt6/bin/qmllint ]]; then
        qmllint=/usr/lib/qt6/bin/qmllint
    elif command -v qmllint >/dev/null 2>&1; then
        qmllint="$(command -v qmllint)"
    else
        echo "check: qmllint was not found" >&2
        exit 1
    fi
fi

qmlimport="${QML_IMPORT_PATH:-/usr/lib/qt6/qml}"
if [[ ! -d "$qmlimport" ]]; then
    echo "check: the QML import path does not exist: $qmlimport" >&2
    exit 1
fi

# ── the tests ──────────────────────────────────────────────────────────────

echo "== tests =="
"$qmltestrunner" -input tests

# ── the lint gate ──────────────────────────────────────────────────────────

echo "== qmllint =="
mapfile -d '' files < <(find bar tests -type f -name '*.qml' -print0 | sort -z)
files+=(shell.qml)
"$qmllint" -I "$qmlimport" "${files[@]}"
printf '\n'
echo "qmllint: ok (known warnings are documented in README.md)"

# ── the hygiene checks ─────────────────────────────────────────────────────

echo "== hygiene =="
failures=0

fail() {
    echo "check: $1" >&2
    failures=1
}

# The underscore modules of Quickshell are private implementation details.
private_imports="$(grep -RInE '^[[:space:]]*import[[:space:]]+Quickshell\.[A-Za-z0-9_]+\._' \
    bar tests shell.qml || true)"
if [[ -n "$private_imports" ]]; then
    echo "$private_imports" >&2
    fail "a private Quickshell module is imported; use its public module instead"
fi

if ! grep -qE '^[[:space:]]*import[[:space:]]+Quickshell\.Wayland[[:space:]]*$' \
    bar/modules/IdleToggle.qml; then
    fail "bar/modules/IdleToggle.qml must use the public Quickshell.Wayland module"
fi

# The metrics are polled once per shell, not once per output: the pollers
# live in the Metrics singleton, never in a module. A module that
# instantiates a Poller would poll once per bar again.
module_pollers="$(grep -RInE '\bPoller[[:space:]]*\{' bar/modules || true)"
if [[ -n "$module_pollers" ]]; then
    echo "$module_pollers" >&2
    fail "a module instantiates its own Poller; the pollers live in the shared Metrics hub"
fi

metrics="bar/Metrics.qml"
pollers_file="bar/MetricsPollers.qml"
if [[ ! -f "$metrics" ]]; then
    fail "bar/Metrics.qml is missing"
elif [[ ! -f "$pollers_file" ]]; then
    fail "bar/MetricsPollers.qml is missing"
else
    if ! grep -qE '^singleton Metrics Metrics\.qml$' bar/qmldir; then
        fail "bar/qmldir does not register the Metrics singleton"
    fi
    if ! grep -qE 'source:[[:space:]]*"MetricsPollers\.qml"' "$metrics"; then
        fail "bar/Metrics.qml does not load the shared pollers"
    fi

    pollers="$(grep -cE '\bPoller[[:space:]]*\{' "$pollers_file" || true)"
    if [[ "$pollers" -ne 6 ]]; then
        fail "$pollers_file has $pollers pollers, expected one per polled metric"
    fi

    for metric in cpu memory temperature network updates backlight; do
        if ! grep -qE "property [A-Za-z]+Metric ${metric}:" "$metrics"; then
            fail "bar/Metrics.qml does not own the $metric metric"
        fi
        if ! grep -qE "property Poller ${metric}Poller:" "$pollers_file"; then
            fail "$pollers_file does not own the $metric poller"
        fi
        if ! grep -qE "metric:[[:space:]]*Metrics\.${metric}[[:space:]]*$" "$pollers_file"; then
            fail "$pollers_file does not poll the $metric metric"
        fi
    done
fi

# The palette is the only place that names a colour. A module that spells
# out a hex colour or an alpha colour bypasses the theme, does not follow a
# palette switch and is a bug even when the value happens to match today.
colour_literals="$(grep -RInE "['\"]#[0-9a-fA-F]{3,8}['\"]" bar \
    --include='*.qml' | grep -vE '^bar/(Theme|ThemePalette)\.qml:' || true)"
if [[ -n "$colour_literals" ]]; then
    echo "$colour_literals" >&2
    fail "a colour is spelled out outside Theme.qml/ThemePalette.qml"
fi

alpha_colours="$(grep -RInE 'Qt\.(rgba|hsla|lighter|darker)' bar \
    --include='*.qml' | grep -vE '^bar/(Theme|ThemePalette)\.qml:' || true)"
if [[ -n "$alpha_colours" ]]; then
    echo "$alpha_colours" >&2
    fail "an alpha colour is built outside Theme.qml/ThemePalette.qml"
fi

if ! grep -qE '^singleton ThemePalette ThemePalette\.qml$' bar/qmldir; then
    fail "bar/qmldir does not register the ThemePalette singleton"
fi
if ! grep -qE '\bThemePalette\.byName\(' bar/Theme.qml; then
    fail "bar/Theme.qml does not read the palette roles"
fi

# The example is a template, never the config the bar reads.
config="config.example.json"
if [[ ! -f "$config" ]]; then
    fail "config.example.json is missing"
else
    if grep -RIn 'config\.example\.json' bar shell.qml >/dev/null; then
        fail "the bar must not read config.example.json; the live config is in \$XDG_CONFIG_HOME"
    fi

    settings_keys="$(sed -n 's/.*root\.value("\([^"]*\)".*/\1/p' \
        bar/Settings.qml | sort -u)"
    if [[ -z "$settings_keys" ]]; then
        fail "could not read the setting keys from bar/Settings.qml"
    fi

    while IFS= read -r key; do
        [[ -n "$key" ]] || continue
        if ! grep -qE "^[[:space:]]*\"${key}\"[[:space:]]*:" "$config"; then
            fail "config.example.json is missing the setting \"$key\""
        fi
    done <<< "$settings_keys"

    config_keys="$(sed -n 's/^[[:space:]]*"\([^"]*\)"[[:space:]]*:.*/\1/p' \
        "$config" | sort -u)"
    extra_keys="$(comm -13 <(printf '%s\n' "$settings_keys") \
        <(printf '%s\n' "$config_keys"))"
    if [[ -n "$extra_keys" ]]; then
        fail "config.example.json has keys that are not settings: $extra_keys"
    fi

    # JSON has no comments, so the schema is documented in the README. The
    # syntax of the file is still checked when a JSON parser is available.
    if command -v jq >/dev/null 2>&1; then
        jq -e . "$config" >/dev/null || fail "config.example.json is not valid json"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import json, sys; json.load(open(sys.argv[1]))' "$config" \
            || fail "config.example.json is not valid json"
    else
        echo "check: warning: jq and python3 are missing, config.example.json was not parsed" >&2
    fi
fi

# The path is literal on purpose: it is the documentation of the live file,
# not a variable of this script.
# shellcheck disable=SC2016
if ! grep -Fq '$XDG_CONFIG_HOME/quickshell/jbar/config.json' README.md; then
    fail "README.md does not document the live config path"
fi
if ! grep -Fiq 'not the live config' README.md; then
    fail "README.md does not say that config.example.json is not the live config"
fi
if ! grep -Fq 'config.example.json' README.md; then
    fail "README.md does not mention config.example.json"
fi
while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    if ! grep -Fq "\`$key\`" README.md; then
        fail "README.md does not document the setting \"$key\""
    fi
done <<< "${settings_keys:-}"
if ! grep -Fq 'tests/check.sh' README.md; then
    fail "README.md does not use tests/check.sh in its test instructions"
fi

# Every command and font the default settings and the modules invoke has to
# be in the requirements list of the README.
requirements=(
    quickshell
    Geist
    "CaskaydiaCove Nerd Font"
    niri
    nmcli
    brightnessctl
    checkupdates
    playerctl
    MPRIS
    rofi
    wlogout
    kitty
    yay
    notify-send
    xdg-open
    qmltestrunner
    qmllint
)
for requirement in "${requirements[@]}"; do
    if ! grep -Fiq -- "$requirement" README.md; then
        fail "README.md does not mention $requirement"
    fi
done

if (( failures != 0 )); then
    echo "check: failed" >&2
    exit 1
fi

echo "check: ok"
