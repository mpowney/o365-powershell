param (
    $BaseTemplate,
    $Template
)

    $Collections = @(
        @{Name = "ContentTypes"; Key = "Id"; DisplayProperty = "Name" },
        @{Name = "Lists"; Key = "Title"; DisplayProperty = "Title"; LeaveIntact = @("Site Pages") },
        @{Name = "SiteFields"; Key = "SchemaXml"; DisplayProperty = "SchemaXml" }
    )

    $Collections | % {
        
        $Name = $_.Name;
        $Key = $_.Key;
        $DisplayProperty = $_.DisplayProperty;
        $LeaveIntact = $_.LeaveIntact;

        $RemoveObjects = @();

        For ($x = 0; $x -lt $Template.$Name.Count; $x++) {

            $CheckValue = $Template.$Name[$x].$Key
            if (($BaseTemplate.$Name | Select-Object -Property $Key).$Key -contains $CheckValue -and $LeaveIntact -notcontains $CheckValue) {
                Write-Host "Removing from property $Name : $($Template.$Name[$x].$DisplayProperty)"
                $RemoveObjects += $Template.$Name[$x]
            }

        }

        $RemoveObjects | % {
            ($Template.$Name).Remove($_) | Out-Null
        }

    }


