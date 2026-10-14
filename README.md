<div align="center">

# Desktop Auto-Organizer

**A PowerShell script that turns a chaotic Windows desktop into a clean folder system using keyword and extension rules. It has a dry-run mode and never overwrites a file.**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

</div>

---

## What it does

Creates a fixed top-level structure on the desktop and routes every loose file or folder into it:

```
Desktop/
├── 00_INBOX/        ← anything without a clear category (nothing gets lost)
├── 01_PROJECTS/     ← 3D_PRINTING · AI_AUTOMATION · OSINT_SECURITY · EMBEDDED_ARDUINO · LABS_NETWORK_SECURITY
├── 02_DOCUMENTS/    ← CV_AND_ADMIN · STUDY_NOTES · SPREADSHEETS_PDFS
├── 03_SHORTCUTS/    ← APPS · GAMES
├── 04_MEDIA/        ← IMAGES · ARCHIVES_INSTALLERS · FONTS · GAMES
└── 05_ARCHIVE/      ← OLD_PROJECTS
```

**Routing order:**

1. **Keyword rules on the name** (regex), e.g. `arduino|esp32|firmware` → `01_PROJECTS\EMBEDDED_ARDUINO`
2. **Extension rules** for files, e.g. `.pdf/.xlsx` → `SPREADSHEETS_PDFS`, `.zip/.exe/.msi` → `ARCHIVES_INSTALLERS`
3. Game shortcuts (`.lnk`/`.url`) are split from app shortcuts
4. **Fallback** → `00_INBOX`

## Safety

- **`-WhatIfMode`** prints every `WOULD MOVE: src -> dest` and touches nothing.
- **No overwrites:** name collisions become `file_1.ext`, `file_2.ext`, …
- The organizer's own folders, `desktop.ini` and the Recycle Bin are skipped.
- Errors are logged per item and the run continues.

## Usage

```powershell
# 1) preview first, nothing is moved
.\TEST_run_preview.bat
#    or: powershell -ExecutionPolicy Bypass -File .\desktop_auto_organizer.ps1 -WhatIfMode

# 2) run for real
.\run_organizer.bat

# organize a different folder
powershell -ExecutionPolicy Bypass -File .\desktop_auto_organizer.ps1 -DesktopPath "D:\Downloads"
```

> If Windows blocks the script: right-click the `.ps1` → Properties → **Unblock** → Apply.

## Customize

Edit the two maps at the top of the script:

- `Get-KeywordCategory` → `$map`: regex pattern → target folder
- `$fileRoutes`: extension → target folder

---

<sub>Built by **Nicolas Di Prospero** · [github.com/nicodiprospero](https://github.com/nicodiprospero)</sub>
