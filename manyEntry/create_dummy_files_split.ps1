# Creates zero-padded range-named folders (0000001_0010000, 0010001_0020000, ...) next to this script.
# Each folder holds 0000001.txt ~ 0010000.txt (zero-padded), and each file contains its own file name (e.g. 0000001.txt -> "0000001.txt").
# Usage: .\create_dummy_files_split.ps1 [-TotalFolders 200] [-FilesPerFolder 10000]
# NOTE: keep this file ASCII-only (PowerShell 5.1 misreads BOM-less UTF-8 Korean text).
param(
    [int]$TotalFolders = 200,      # 200 folders x 10000 files = 2,000,000 files
    [int]$FilesPerFolder = 10000
)

$root = $PSScriptRoot
$total = $TotalFolders * $FilesPerFolder
$pad = '0' * "$total".Length   # zero-pad folder names so they sort correctly (2,000,000 -> 7 digits)
$sw = [System.Diagnostics.Stopwatch]::StartNew()

for ($f = 0; $f -lt $TotalFolders; $f++) {
    $start = $f * $FilesPerFolder + 1
    $end = ($f + 1) * $FilesPerFolder
    $folderName = "{0}_{1}" -f $start.ToString($pad), $end.ToString($pad)
    $folder = [System.IO.Path]::Combine($root, $folderName)
    [void][System.IO.Directory]::CreateDirectory($folder)

    for ($i = 1; $i -le $FilesPerFolder; $i++) {
        $name = $i.ToString($pad) + ".txt"
        # Overwrites if the file already exists, so re-running is safe.
        [System.IO.File]::WriteAllText([System.IO.Path]::Combine($folder, $name), $name)
    }

    $done = ($f + 1) * $FilesPerFolder
    $rate = [int]($done / [Math]::Max($sw.Elapsed.TotalSeconds, 1))
    Write-Progress -Activity "Creating dummy files" -Status "$done / $total  (folder $folderName, $rate files/s)" -PercentComplete ($done * 100 / $total)
}

Write-Host "Done: $total files in $TotalFolders folders, elapsed $($sw.Elapsed.ToString('hh\:mm\:ss'))"
