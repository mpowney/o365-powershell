# Remove-PnPTemplateFromTemplate.ps1

Takes a PNP provisioning template from a base site, and removes elements found in a template from another site, the result is the difference of the two templates.  

This script is useful when the PNP provisioning template to be appliedto destination sites should only contain the minimum changes.  Instead of including the definitions of all site columns, content types, lists, etc, the resulting provisioning template will include just the artifacts specific to the working site.

## PRE-REQUISITES

* PowerShell 5.x
* [PnP PowerShell v3.22.2006.2](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps)

## OUTPUT
None - this script updates the object specified in the ```-Template``` parameter directly


## PARAMETERS

Note: both the ```-BaseTemplate``` and ```-Template``` parameters must be provided as an in-memory object representation of PnP Provisioning templates.  These can be obtained using the [```-OutputInstance``` switch parameter of Get-PnPProvisioningTemplate](https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpprovisioningtemplate?view=sharepoint-ps#parameters)

### -BaseTemplate
The base template obtained from the source site

```yaml
Type: PnPProvisioningTemplate
Required: True
Position: Named
Accept pipeline input: False
```

### -Template
The template to remove artifacts from, found in the base template

```yaml
Type: PnPProvisioningTemplate
Required: True
Position: Named
Accept pipeline input: False
```


## Examples

### ------------------EXAMPLE 1------------------
```powershell
Connect-PnPOnline https://contoso.sharepoint.com/sites/base-template
$BaseTemplate = Get-PnPProvisioningTemplate -OutputInstance

Connect-PnPOnline https://contoso.sharepoint.com/sites/template-working-site
$WorkingTemplate = Get-PnPProvisioningTemplate -OutputInstance

.\Remove-PnPTemplateFromTemplate.ps1 -BaseTemplate $BaseTemplate -Template $WorkingTemplate

Connect-PnPOnline https://contoso.sharepoint.com/sites/apply-template-here
Apply-PnPProvisioningTemplate $WorkingTemplate
```

Obtains a base template from site ```/sites/base-template```, gets the working template from site ```/sites/template-working-site``` removes the artifacts found in the base template from the working template, then applies the template that contains just the modified artifact to a new site ```/sites/apply-template-here```