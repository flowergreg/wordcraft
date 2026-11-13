#!/usr/bin/env bash
# Compila la versione personale per Windows x64 da Linux (vedi il promemoria nel progetto Claude).
# Uso: personale/build-windows.sh   (dalla radice del repository, ramo mie-modifiche)
set -euo pipefail
ROOT=$(pwd)
DEPS=${DEPS:-$HOME/deps}
mkdir -p "$DEPS"
command -v x86_64-w64-mingw32-gcc >/dev/null || sudo apt-get install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 || apt-get install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
rustup target add x86_64-pc-windows-gnu
if [ ! -d "$DEPS/craft-i18n" ]; then git clone -q --filter=blob:none https://github.com/storytold/craft-i18n "$DEPS/craft-i18n"; fi
git -C "$DEPS/craft-i18n" fetch -q origin && git -C "$DEPS/craft-i18n" checkout -q -f "$(cat craft-i18n.rev)"
# Traduzioni italiane delle voci aggiunte in questa versione.
cat personale/it-aggiunte.tsv >> "$DEPS/craft-i18n/locales/it/wordcraft.tsv"
if [ ! -d "$DEPS/craft-fonts" ]; then git clone -q --depth 1 https://github.com/storytold/craft-fonts "$DEPS/craft-fonts"; fi
export CRAFT_I18N_DIR="$DEPS/craft-i18n" CRAFT_FONTS_DIR="$DEPS/craft-fonts"
export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc CARGO_PROFILE_RELEASE_LTO=false
cargo build --release -p wordcraft --target x86_64-pc-windows-gnu
OUT="$ROOT/target/WordCraft-personale"
rm -rf "$OUT" && mkdir -p "$OUT/font-licenses"
cp target/x86_64-pc-windows-gnu/release/wordcraft.exe LICENSE-MIT LICENSE-APACHE NOTICE ATTRIBUTION.md personale/LEGGIMI.txt "$OUT/"
for f in "$DEPS"/craft-fonts/fonts/*/OFL.txt; do cp "$f" "$OUT/font-licenses/OFL-$(basename "$(dirname "$f")").txt"; done
(cd "$ROOT/target" && rm -f WordCraft-personale-win-x64.zip && zip -qr -9 WordCraft-personale-win-x64.zip WordCraft-personale)
echo "Pronto: target/WordCraft-personale-win-x64.zip"
