# ElectroFISH downloads

Installers for **ElectroFISH** (ELECTROmagnetic Field Investigation of Submarine High voltage cables; called EM Calculator up to version 2.7), a desktop app for Windows and macOS that computes the magnetic and electric fields around subsea power cables. It was developed in the Electrical Power Engineering group at the University of Southampton.

## Install on Windows

1. Open the [latest release](https://github.com/zod1ach/em-calculator-downloads/releases/latest).
2. Download `ElectroFISH-Setup-<version>.exe` and run it. It installs for your user only, so administrator rights are not needed. An older version is replaced; your projects are kept.
3. The installer is not code-signed yet, so Windows SmartScreen may ask you to confirm: choose **More info**, then **Run anyway**.

To check a download, compare its SHA-256 with the `.sha256` file beside it.

### From the command line

In PowerShell:

```powershell
irm https://raw.githubusercontent.com/zod1ach/em-calculator-downloads/main/install.ps1 | iex
```

This finds the latest release, downloads the installer to your Downloads folder, checks it against the published SHA-256 and starts it. Set `$env:EM_INSTALL_SILENT = "1"` first to install without the installer's pages, or `$env:EM_DOWNLOAD_ONLY = "1"` to only download and check it.

From `cmd`, the same thing is:

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/zod1ach/em-calculator-downloads/main/install.ps1 | iex"
```

## Install on a Mac

1. Open the [latest release](https://github.com/zod1ach/em-calculator-downloads/releases/latest).
2. Download the disk image for your Mac: `ElectroFISH-<version>-mac-arm64.dmg` for Apple silicon (M1 or later), or `ElectroFISH-<version>-mac-x64.dmg` for an Intel processor. The Apple menu, **About This Mac**, says which you have.
3. Open the disk image and drag **ElectroFISH** into **Applications**. An older version is replaced; your projects are kept.
4. Open ElectroFISH. The app is not signed with an Apple developer certificate, so macOS stops it the first time. Open **System Settings**, **Privacy & Security**, scroll to the message about ElectroFISH, press **Open Anyway** and confirm. This is needed once.

If macOS says the app is damaged, run this once in Terminal and open the app again:

```sh
xattr -dr com.apple.quarantine "/Applications/ElectroFISH.app"
```

### From the command line

In Terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/zod1ach/em-calculator-downloads/main/install.sh | sh
```

This finds the latest release, downloads the disk image for your Mac's processor to your Downloads folder, checks it against the published SHA-256 and copies ElectroFISH into Applications. Installed this way, the app opens without the Open Anyway step. Put `EM_DOWNLOAD_ONLY=1` before `sh` to only download and check it.

## Updates

On Windows, from version 2.7.0 the app checks this page for new versions. It shows the release notes and asks before downloading anything. A backup copy of your projects is made before an update is installed.

On a Mac the app does not update itself: install each new version as above.

## Help

The user manual is inside the app: **Help**, then **User manual**, or press F1.

## Source files

This repository holds installers and release notes only. The "Source code" links that GitHub adds to every release hold this page and the install scripts, not the app. The app's source files are available on request.
