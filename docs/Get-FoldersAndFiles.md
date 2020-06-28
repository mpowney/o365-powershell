# Get-FoldersAndFiles.ps1

Produces a list of all folders found in a SharePoint document library.  The following information is extracted on each folder:
* total number of files
* total file size (in bytes) of all files inside
* last modified date of all files inside

## Pre-requisites

* PowerShell 5.x
* [PnP PowerShell v3.22.2006.2](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps)


## PARAMETERS

### -Url
The URL of the site in which the folder or document library you'd like to interrogate is located

```yaml
Type: String
Required: True
Position: Named
Accept pipeline input: False
```

### -UseWebLogin
Direct Connect-PnPOnline to use the web login option, useful if the target tenant has multi-factor authentication enabled

```yaml
Type: SwitchParameter
Position: Named
Accept pipeline input: False
```

### -DocumentLibrary
The title or GUID of the document library to list out the folders (not required if the Path parameter is specified)

```yaml
Type: String
Required: False
Position: Named
Accept pipeline input: False
```

### -Path
The server-relative path of the folder to list out the sub-folders (not required if the DocumentLibrary parameter is specified)

```yaml
Type: String
Required: False
Position: Named
Accept pipeline input: False
```

### -DisableProgressCursor
Use this parameter if the spinning cursor that indicates progress causes you any problems

```yaml
Type: SwitchParameter
Position: Named
Accept pipeline input: False
```

## Examples

### ------------------EXAMPLE 1------------------
```powershell
.\Get-FoldersAndFiles.ps1 -Url https://tenant.sharepoint.com/sites/sitename -UseWebLogin -Path "/sites/site/Document library name/Sub folder name" | Sort-Object -Property ServerRelativeUrl
```

Exports the folder information of a specific sub folder, [UseWebLogin](https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/connect-pnponline?view=sharepoint-ps#parameters) when connecting to the tenant, and sort the output by the ServerRelativePath property


### ------------------EXAMPLE 2------------------

```powershell
.\Get-FoldersAndFiles.ps1 -Url https://tenant.sharepoint.com/sites/sitename -UseWebLogin -DocumentLibrary "Document library name" | Sort-Object -Property ServerRelativeUrl
```

Exports all the folder information of a document library, [UseWebLogin](https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/connect-pnponline?view=sharepoint-ps#parameters) when connecting to the tenant, and sort the output by the ServerRelativePath property
