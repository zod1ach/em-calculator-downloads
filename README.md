# EM Calculator downloads

Installers for **EM Calculator**, a Windows desktop app that computes the magnetic and electric fields around subsea power cables. It was developed in the Electrical Power Engineering group at the University of Southampton.

## Install

1. Open the [latest release](https://github.com/zod1ach/em-calculator-downloads/releases/latest).
2. Download `EM-Calculator-Setup-<version>.exe` and run it. It installs for your user only, so administrator rights are not needed. An older version is replaced; your projects are kept.
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

## Updates

From version 2.7.0 the app checks this page for new versions. It shows the release notes and asks before downloading anything. A backup copy of your projects is made before an update is installed.

## Help

The user manual is inside the app: **Help**, then **User manual**, or press F1.

This repository holds installers and release notes only.
