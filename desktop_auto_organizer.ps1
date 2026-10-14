param(
    [string]$DesktopPath = [Environment]::GetFolderPath("Desktop"),
    [switch]$WhatIfMode
)

$ErrorActionPreference = "Continue"

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] $Message"
}

function Ensure-Folder {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-SafeName {
    param([string]$Name)
    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $safe = -join ($Name.ToCharArray() | ForEach-Object {
        if ($invalid -contains $_) { "_" } else { $_ }
    })
    return $safe.Trim()
}

function Move-Safely {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$DestinationFolder
    )

    Ensure-Folder $DestinationFolder

    $item = Get-Item -LiteralPath $Source -ErrorAction SilentlyContinue
    if (-not $item) { return }

    $name = $item.Name
    $dest = Join-Path $DestinationFolder $name

    if ($item.FullName -eq $dest) { return }

    if (Test-Path -LiteralPath $dest) {
        $stem = [IO.Path]::GetFileNameWithoutExtension($name)
        $ext = [IO.Path]::GetExtension($name)
        $i = 1
        do {
            $newName = "{0}_{1}{2}" -f $stem, $i, $ext
            $dest = Join-Path $DestinationFolder $newName
            $i++
        } while (Test-Path -LiteralPath $dest)
    }

    if ($WhatIfMode) {
        Write-Log "WOULD MOVE: $($item.FullName) -> $dest"
    } else {
        try {
            Move-Item -LiteralPath $item.FullName -Destination $dest -Force
            Write-Log "MOVED: $($item.Name) -> $DestinationFolder"
        } catch {
            Write-Log "FAILED: $($item.FullName) :: $($_.Exception.Message)"
        }
    }
}

function Get-KeywordCategory {
    param([string]$Name)

    $n = $Name.ToLowerInvariant()

    $map = @(
        @{ Pattern = 'jarvis|ai|ollama|open-webui|vision|assistant|voice'; Category = '01_PROJECTS\AI_AUTOMATION' }
        @{ Pattern = 'meta|metaseeker|metahunter|osint|relat[oó]rio|report'; Category = '01_PROJECTS\OSINT_SECURITY' }
        @{ Pattern = '3d|printer|bambu|creality|shiplab|farm|voron|am8|stl|slicer'; Category = '01_PROJECTS\3D_PRINTING' }
        @{ Pattern = 'arduino|esp32|esp8266|firmware'; Category = '01_PROJECTS\EMBEDDED_ARDUINO' }
        @{ Pattern = 'packet tracer|cisco|debian|kali|linux|openssl|hydra|pcsx2|pcs6|redes|sera'; Category = '01_PROJECTS\LABS_NETWORK_SECURITY' }
        @{ Pattern = 'cv|curr[ií]culo|declarac'; Category = '02_DOCUMENTS\CV_AND_ADMIN' }
        @{ Pattern = 'tutorial|apresenta'; Category = '02_DOCUMENTS\STUDY_NOTES' }
        @{ Pattern = 'zoom|spotify|opera|stremio|rave|tlauncher|tuneskit'; Category = '03_SHORTCUTS\APPS' }
        @{ Pattern = 'fnaf|freddy|transformice|rockstar|9 kings|the king is watching'; Category = '04_MEDIA\GAMES' }
        @{ Pattern = 'photo|image|img|screenshot|2025'; Category = '04_MEDIA\IMAGES' }
        @{ Pattern = 'font'; Category = '04_MEDIA\FONTS' }
    )

    foreach ($entry in $map) {
        if ($n -match $entry.Pattern) {
            return $entry.Category
        }
    }

    return $null
}

$rootMap = @{
    "00_INBOX" = Join-Path $DesktopPath "00_INBOX"
    "01_PROJECTS" = Join-Path $DesktopPath "01_PROJECTS"
    "02_DOCUMENTS" = Join-Path $DesktopPath "02_DOCUMENTS"
    "03_SHORTCUTS" = Join-Path $DesktopPath "03_SHORTCUTS"
    "04_MEDIA" = Join-Path $DesktopPath "04_MEDIA"
    "05_ARCHIVE" = Join-Path $DesktopPath "05_ARCHIVE"
}

foreach ($p in $rootMap.Values) { Ensure-Folder $p }

$subFolders = @(
    "01_PROJECTS\3D_PRINTING",
    "01_PROJECTS\AI_AUTOMATION",
    "01_PROJECTS\OSINT_SECURITY",
    "01_PROJECTS\EMBEDDED_ARDUINO",
    "01_PROJECTS\LABS_NETWORK_SECURITY",
    "02_DOCUMENTS\CV_AND_ADMIN",
    "02_DOCUMENTS\STUDY_NOTES",
    "02_DOCUMENTS\SPREADSHEETS_PDFS",
    "03_SHORTCUTS\APPS",
    "03_SHORTCUTS\GAMES",
    "04_MEDIA\IMAGES",
    "04_MEDIA\ARCHIVES_INSTALLERS",
    "04_MEDIA\FONTS",
    "04_MEDIA\GAMES",
    "05_ARCHIVE\OLD_PROJECTS"
)

foreach ($rel in $subFolders) {
    Ensure-Folder (Join-Path $DesktopPath $rel)
}

# Skip folders the script itself manages, system items, and launchers that should remain accessible.
$skipNames = @(
    "Lixeira",
    "Recycle Bin",
    "desktop.ini",
    "00_INBOX",
    "01_PROJECTS",
    "02_DOCUMENTS",
    "03_SHORTCUTS",
    "04_MEDIA",
    "05_ARCHIVE"
)

# File extension routing
$fileRoutes = @{
    ".zip"  = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".rar"  = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".7z"   = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".iso"  = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".msi"  = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".exe"  = "04_MEDIA\ARCHIVES_INSTALLERS"
    ".pdf"  = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".doc"  = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".docx" = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".xls"  = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".xlsx" = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".csv"  = "02_DOCUMENTS\SPREADSHEETS_PDFS"
    ".txt"  = "02_DOCUMENTS\STUDY_NOTES"
    ".md"   = "02_DOCUMENTS\STUDY_NOTES"
    ".png"  = "04_MEDIA\IMAGES"
    ".jpg"  = "04_MEDIA\IMAGES"
    ".jpeg" = "04_MEDIA\IMAGES"
    ".webp" = "04_MEDIA\IMAGES"
    ".gif"  = "04_MEDIA\IMAGES"
    ".svg"  = "04_MEDIA\IMAGES"
    ".ttf"  = "04_MEDIA\FONTS"
    ".otf"  = "04_MEDIA\FONTS"
    ".lnk"  = "03_SHORTCUTS\APPS"
    ".url"  = "03_SHORTCUTS\APPS"
}

Write-Log "Scanning desktop: $DesktopPath"

$items = Get-ChildItem -LiteralPath $DesktopPath -Force | Where-Object { $skipNames -notcontains $_.Name }

foreach ($item in $items) {
    try {
        $targetRel = $null

        if ($item.PSIsContainer) {
            $targetRel = Get-KeywordCategory -Name $item.Name
            if (-not $targetRel) {
                # Folders without a clear category go to inbox instead of being scattered.
                $targetRel = "00_INBOX"
            }
        } else {
            $ext = $item.Extension.ToLowerInvariant()
            $targetRel = Get-KeywordCategory -Name $item.Name

            if (-not $targetRel -and $fileRoutes.ContainsKey($ext)) {
                $targetRel = $fileRoutes[$ext]
            }

            if (-not $targetRel) {
                $targetRel = "00_INBOX"
            }

            # Game shortcuts get separated from app shortcuts
            if (($ext -eq ".lnk" -or $ext -eq ".url") -and ($item.Name.ToLowerInvariant() -match 'fnaf|freddy|transformice|rockstar|9 kings|minecraft|steam')) {
                $targetRel = "03_SHORTCUTS\GAMES"
            }
        }

        $destFolder = Join-Path $DesktopPath $targetRel
        Move-Safely -Source $item.FullName -DestinationFolder $destFolder
    } catch {
        Write-Log "ERROR with $($item.FullName): $($_.Exception.Message)"
    }
}

Write-Log "Done."
