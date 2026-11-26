#!/bin/sh
# Installs the latest ElectroFISH (EM Calculator up to version 2.7) on a Mac for
# the current user.
#
#   curl -fsSL https://raw.githubusercontent.com/zod1ach/em-calculator-downloads/main/install.sh | sh
#
# It finds the latest release, downloads the disk image for this Mac's
# processor, checks the download against the published SHA-256, and copies
# the app into the Applications folder. An older copy is replaced, under either
# name; your projects are kept.
#
# Set these before running to change what it does:
#   EM_DOWNLOAD_ONLY=1    download and check the disk image, do not install it
#   EM_INSTALL_DIR=...    where to keep the download (default: your Downloads folder)

set -eu

repo="zod1ach/em-calculator-downloads"
base="https://github.com/$repo/releases"

fail() {
  echo "$1" >&2
  exit 1
}

[ "$(uname -s)" = "Darwin" ] || fail "This script is for macOS. On Windows use install.ps1."

arch=$(uname -m)
# A shell running under Rosetta reports an Intel processor on Apple silicon.
if [ "$arch" = "x86_64" ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = "1" ]; then
  arch=arm64
fi
case "$arch" in
  arm64) kind=arm64 ;;
  x86_64) kind=x64 ;;
  *) fail "This Mac's processor ($arch) is not supported." ;;
esac

echo "Looking up the latest ElectroFISH release..."
latest=$(curl -fsSL -o /dev/null -w '%{url_effective}' "$base/latest") \
  || fail "The downloads page could not be reached."
tag=${latest##*/}
version=${tag#v}
case "$version" in
  '' | *[!0-9.]*) fail "The latest release could not be found." ;;
esac
name="ElectroFISH-$version-mac-$kind.dmg"
# Versions up to 2.7 were published as EM Calculator.
if ! curl -fsSL -o /dev/null "$base/download/$tag/$name.sha256"; then
  name="EM-Calculator-$version-mac-$kind.dmg"
fi

folder=${EM_INSTALL_DIR:-$HOME/Downloads}
mkdir -p "$folder"
target="$folder/$name"

echo "Downloading $name to $folder ..."
curl -fL --progress-bar -o "$target" "$base/download/$tag/$name" \
  || fail "Release $tag has no disk image for this Mac ($name), or the download failed."

echo "Checking the download..."
expected=$(curl -fsSL "$base/download/$tag/$name.sha256" | awk '{ print tolower($1); exit }') \
  || fail "Release $tag has no SHA-256 file, so the download cannot be checked."
actual=$(shasum -a 256 "$target" | awk '{ print $1 }')
case "$expected" in
  ???????????????????????????????????????????????????????????????? ) ;;
  *) fail "The published SHA-256 could not be read." ;;
esac
if [ "$actual" != "$expected" ]; then
  rm -f "$target"
  fail "The download does not match the published SHA-256 and was deleted. Try again."
fi
echo "The download matches the published SHA-256."

if [ "${EM_DOWNLOAD_ONLY:-}" = "1" ]; then
  echo "Saved $target. Open it and drag the app into Applications to install version $version."
  exit 0
fi

if pgrep -x "ElectroFISH" > /dev/null 2>&1 || pgrep -x "EM Calculator" > /dev/null 2>&1; then
  fail "The app is open. Quit it and run this again. The download is saved as $target."
fi

dest="/Applications"
if [ ! -w "$dest" ]; then
  dest="$HOME/Applications"
  mkdir -p "$dest"
fi

mount=$(mktemp -d "${TMPDIR:-/tmp}/em-calculator.XXXXXX")
cleanup() {
  hdiutil detach "$mount" -quiet > /dev/null 2>&1 || true
  rmdir "$mount" > /dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Installing version $version in $dest ..."
hdiutil attach "$target" -nobrowse -readonly -noautoopen -mountpoint "$mount" > /dev/null \
  || fail "The disk image could not be opened."
app=""
for candidate in "ElectroFISH.app" "EM Calculator.app"; do
  if [ -d "$mount/$candidate" ]; then
    app="$candidate"
    break
  fi
done
[ -n "$app" ] || fail "The disk image does not hold the app."
# An older copy goes, whichever name it was installed under.
rm -rf "$dest/ElectroFISH.app" "$dest/EM Calculator.app"
ditto "$mount/$app" "$dest/$app"
# The app is not signed with an Apple developer certificate. Without this mark
# macOS opens it without asking to allow it first.
xattr -dr com.apple.quarantine "$dest/$app" > /dev/null 2>&1 || true

echo "${app%.app} $version is installed. Open it from Launchpad or from $dest."
