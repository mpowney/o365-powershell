# Pre-requesites: 
#   PowerShell 5.x, 
#   PnP PowerShell v3.22.2006.2 
#   See https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps for PnP install instructions

# Example usage:

# .\Get-FoldersAndFiles.ps1 -Url https://tenant.sharepoint.com/sites/sitename -UseWebLogin -Path "/sites/site/Document library name/Sub folder name" | Sort-Object -Property ServerRelativeUrl
# .\Get-FoldersAndFiles.ps1 -Url https://tenant.sharepoint.com/sites/sitename -UseWebLogin -DocumentLibrary "Document library name" | Sort-Object -Property ServerRelativeUrl

Param (
    [string] $Url,
    [switch] $UseWebLogin,
    [string] $DocumentLibrary = $null,
    [string] $Path = $null
)

Connect-PnPOnline -Url $Url -UseWebLogin:$UseWebLogin

if ($null -ne $DocumentLibrary -and [System.String]::Empty -ne $DocumentLibrary) {
    Write-Debug "Getting doc library's root folder"
    
    $global:List = Get-PnPList $DocumentLibrary
    $global:RootFolder = $List.RootFolder

}
else {
    Write-Debug "Getting folder from path ""$Path"""
    $global:RootFolder = Get-PnPFolder $Path
}

if ($null -eq $RootFolder) {
    Write-Error "Root folder not found, aborting."
    exit
}

$global:CumulativeFolderInformation = [System.Collections.ArrayList]@()

$anim = @("|", "/", "-", "\") # Animation sequence characters

function ProgressCursorAnimation() {

    if ($null -eq $global:AnimationSequence) {
        Write-Host " " -NoNewline
        $global:AnimationSequence = 0
    }
    else {
        $global:AnimationSequence++
        if ($global:AnimationSequence -gt $anim.Length) {
            $global:AnimationSequence = 0
        }
    }

    Write-Host "`b$($anim[$global:AnimationSequence])" -NoNewline -ForegroundColor Yellow

}

function CompleteCursorAnimation() {

    if ($null -ne $AnimationSequence) {
        Write-Host "`b " -NoNewline
    }
    
}


function AddFolderInformationToParents ($FolderInformation, $FolderName, [bool]$Recurse) {
    $ParentFolder = $FolderName.SubString(0, $FolderName.LastIndexOf("/"))
    Write-Debug $ParentFolder

    $UpdateFolder = $CumulativeFolderInformation | ? { $_.ServerRelativeUrl -eq $ParentFolder}
    if ($null -ne $UpdateFolder) {
        $UpdateFolder.FileCount += $FolderInformation.FileCount
        $UpdateFolder.FileSize += $FolderInformation.FileSize
        if ($UpdateFolder.TimeLastModified -lt $FolderInformation.TimeLastModified) {
            $UpdateFolder.TimeLastModified = $FolderInformation.TimeLastModified
        }

    }

    if ($true -eq $Recurse) {
        if ($ParentFolder.IndexOf("/") -gt -1) {
            AddFolderInformationToParents $FolderInformation $ParentFolder $Recurse
        }
    }
}

function GetFolderInformation ($Folder, [bool]$Recurse) {

    ProgressCursorAnimation

    (Get-PnPContext).Load($Folder.Files)
    (Get-PnPContext).Load($Folder.Folders)
    (Get-PnPContext).ExecuteQuery()

    # $Folder.Files | Select-Object ServerRelativeUrl, Length, TimeLastModified

    $TotalFilesSize = 0
    $GreatestModifiedTime = New-Object System.DateTime
    $Folder.Files | % { 
        $TotalFilesSize += $_.Length 
        if ($GreatestModifiedTime -lt $_.TimeLastModified) {
            $GreatestModifiedTime = $_.TimeLastModified
        }
    }

    Write-Debug "Adding folder ""$($Folder.ServerRelativeUrl)"" to cumulative folder store"

    $CurrentFolderInformation = [PSCustomObject]@{
        ServerRelativeUrl = $Folder.ServerRelativeUrl;
        FileCount = $Folder.Files.Count;
        FileSize = $TotalFilesSize;
        TimeLastModified = $GreatestModifiedTime;
    }

    $CumulativeFolderInformation.Add($CurrentFolderInformation) | Out-Null

    AddFolderInformationToParents $CurrentFolderInformation $CurrentFolderInformation.ServerRelativeUrl $true

    if ($true -eq $Recurse) {
        $Folder.Folders | % {
            GetFolderInformation $_ $Recurse
        }
    }

}

GetFolderInformation $RootFolder $true

CompleteCursorAnimation

$CumulativeFolderInformation | Select-Object ServerRelativeUrl, FileCount, FileSize, TimeLastModified
