# Installs the latest EM Calculator for the current user.
#
#   irm https://raw.githubusercontent.com/zod1ach/em-calculator-downloads/main/install.ps1 | iex
#
# It finds the latest release, downloads its installer, checks the download
# against the published SHA-256, and starts the installer.
#
# Set these before running to change what it does:
#   $env:EM_INSTALL_SILENT = "1"   install without showing the installer's pages
#   $env:EM_DOWNLOAD_ONLY  = "1"   download and check the installer, do not run it
#   $env:EM_INSTALL_DIR    = "..." where to keep the download (default: your Downloads folder)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = "zod1ach/em-calculator-downloads"
$headers = @{ "User-Agent" = "em-calculator-install"; "Accept" = "application/vnd.github+json" }

Write-Host "Looking up the latest EM Calculator release..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers
$installer = $release.assets | Where-Object { $_.name -match '^EM-Calculator-Setup-[0-9.]+\.exe$' } | Select-Object -First 1
if (-not $installer) { throw "The latest release ($($release.tag_name)) has no installer." }
$checksum = $release.assets | Where-Object { $_.name -eq "$($installer.name).sha256" } | Select-Object -First 1
if (-not $checksum) { throw "The latest release ($($release.tag_name)) has no SHA-256 file, so the download cannot be checked." }

$folder = $env:EM_INSTALL_DIR
if (-not $folder) { $folder = Join-Path $env:USERPROFILE "Downloads" }
if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Force $folder | Out-Null }
$target = Join-Path $folder $installer.name

$megabytes = [Math]::Round($installer.size / 1MB)
Write-Host "Downloading $($installer.name) ($megabytes MB) to $folder ..."
Invoke-WebRequest -Uri $installer.browser_download_url -OutFile $target -Headers @{ "User-Agent" = "em-calculator-install" } -UseBasicParsing

Write-Host "Checking the download..."
$published = (Invoke-RestMethod -Uri $checksum.browser_download_url -Headers @{ "User-Agent" = "em-calculator-install" })
if ($published -is [byte[]]) { $published = [Text.Encoding]::UTF8.GetString($published) }
$expected = ("$published".Trim() -split '\s+')[0].ToLower()
$actual = (Get-FileHash -Path $target -Algorithm SHA256).Hash.ToLower()
if ($expected -notmatch '^[0-9a-f]{64}$') { throw "The published SHA-256 could not be read." }
if ($actual -ne $expected) {
  Remove-Item $target -Force
  throw "The download does not match the published SHA-256 and was deleted. Try again."
}
Write-Host "The download matches the published SHA-256."

if ($env:EM_DOWNLOAD_ONLY -eq "1") {
  Write-Host "Saved $target. Run it to install EM Calculator $($release.tag_name)."
  return
}

if ($env:EM_INSTALL_SILENT -eq "1") {
  Write-Host "Installing EM Calculator $($release.tag_name)..."
  $process = Start-Process -FilePath $target -ArgumentList "/S" -Wait -PassThru
  if ($process.ExitCode -ne 0) { throw "The installer ended with code $($process.ExitCode)." }
  Write-Host "EM Calculator $($release.tag_name) is installed. Open it from the Start menu."
} else {
  Write-Host "Starting the installer for EM Calculator $($release.tag_name)..."
  Start-Process -FilePath $target
}
