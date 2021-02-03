# Check-ValoTabsWebparts.ps1

Looks at a Valo hub site, and finds all of the pages where the Valo Tabs web part is located.

## PRE-REQUISITES

* PowerShell 7.x
* [PnP.PowerShell v1.x](https://pnp.github.io/powershell/)

## OUTPUT
A list of pages that include the Valo Tabs web part in its content.  

**Note:** The Valo Tabs web part is found by the following GUID: ```5d521df6-c396-48ac-9c4b-f76d6a5954de```


## PARAMETERS


### -valoHubUrl
The URL of the Valo Hub site to query

```yaml
Type: string
Required: True
Position: Named
Accept pipeline input: False
```

### -credentials
A reference to stored web credentials to use when connecting to the environment

```yaml
Type: string
Required: True, if -useMFA parameter is not specified
Position: Named
Accept pipeline input: False
```

### -useMFA


```yaml
Type: switch
Required: True
Position: Named
Accept pipeline input: False
```


## Examples

### ------------------EXAMPLE 1------------------
```powershell
.\Check-ValoTabsWebparts.ps1 -valuHubUrl https://contoso.sharepoint.com/sites/tea-point -useMFA
```

Connect with MFA (browser based authentication experience) to the hub site ```https://contoso.sharepoint.com/sites/tea-point```, to find all files with a Valo Tabs web part 
