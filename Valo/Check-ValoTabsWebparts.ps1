param (
	[Parameter(Mandatory = $true, ParameterSetName = "SiteURLWithCreds", Position = 0)]
	[Parameter(Mandatory = $true, ParameterSetName = "SiteURLWithMFA", Position = 0)]
	[string]$valoHubUrl,
	[Parameter(Mandatory = $true, ParameterSetName = "SiteURLWithCreds", Position = 1)]
	$credentials,
	[Parameter(Mandatory = $true , ParameterSetName = "SiteURLWithMFA", Position = 1)]
	[switch]$useMFA,
	$logFileName = ""    
)

$tabsWebPartId = "5d521df6-c396-48ac-9c4b-f76d6a5954de"


function Log {
	param (
		[string]$log,
		[string]$level = "Info",
		[string]$filePath = $logFileName
	)

	$wrappedLog = "[$([DateTime]::Now.ToString("yyyy-MM-dd-hh:mm:ss"))] [$level]: $log"
	$color = "White";
	if ($level -eq "Warning") {
		$color = "Yellow";
	}
	elseif ($level -eq "Error") {
		$color = "Red";
	}
	elseif ($level -eq "OK") {
		$color = "darkgreen"
	}

	Write-Host $wrappedLog -ForegroundColor $color
	if ($filePath) {
		Add-Content -Path $filePath -Value $wrappedLog
	}
}


# Search all the pages containing the WebPart
function Search-ValoTabsPages {
	param (
		$hubsiteId
	)
	
	$searchResults = Submit-PnPSearchQuery -Query "FileExtension:aspx (contentclass:STS_ListItem_WebPageLibrary OR SiteId:$hubsiteId) DepartmentID:{$hubsiteId}" -TrimDuplicates $false
	$pages = $searchResults.ResultRows | ForEach-Object { 
		@{ 
			Web = $_["SPWebUrl"]
			Url = $_["OriginalPath"]
		}
	}
	
	return $pages
}

function Ensure-PageUrl {
	param (
		$webUrl,
		$pageUrl
	)

	#$ In case the result is not a page, obtain the home page URL
	if (!$pageUrl.EndsWith(".aspx")) {
		$webConnection = Get-Connection -webUrl $webUrl -credentials $credentials
		$web = Get-PnPWeb -Includes WelcomePage
		$pageUrl = $webUrl + "/" + $web.WelcomePage
	}

	return $pageUrl;
}

function Get-Connection {
	param(
		$webUrl,
		$credentials
	)

    $currentWebRelativeUrl = (Get-PnPProperty -Property Url -ClientObject (Get-PnPContext).Web)

    if ($currentWebRelativeUrl.ToLower() -eq $webUrl.ToLower()) {
        # Log -log "Already connected to $($currentWebRelativeUrl.ToLower())" -level Warning
    } 
    else {

        # Not already connected, perform connection
        Try {
            # Log -log "Connecting to web. WebUrl='$webUrl'"
            if ($useMFA.IsPresent) {
                # Log -log "MFA"
                $connection = Connect-PnPOnline -Url $webUrl -LaunchBrowser -PnPManagementShell
                # [void](Read-Host 'Press Enter to continue')        
            }
            else {
                $connection = Connect-PnPOnline -Url $webUrl -Credentials $credentials -ReturnConnection
            }
            # Log -log "Connected to web. WebUrl='$webUrl'"
            return $connection;
        }
        Catch {
            $errMessage = $_.Exception.Message
            Log -log "Cannot connect to web. WebUrl='$($webUrl)' ; Exception='$errMessage'"
            Return $null;
        }
    
    }

}

function Check-TabsWebParts {
	param (
		$pages,
		$credentials
	)
    
    $alreadyCheckedPages = @{}

	# For each page
	$pages | ForEach-Object {
		$page = $_

		If ($null -eq $page.Url) { Return }
		If ($null -eq $page.Web) { Return }

		$connection = Get-Connection -webUrl $page.Web -credentials $credentials

		# Get the name of the page (last part of the URL)
        $pageUrl = Ensure-PageUrl  -webUrl $page.Web -pageUrl $page.Url
        
        if ($true -eq $alreadyCheckedPages.ContainsKey($pageUrl)) {
            Log -log "Already checked $pageUrl, skipping" -level Warning
            Return

        }

        $alreadyCheckedPages.Add($pageUrl, $true)

        $webUrl = $page.Web
        $pageName = $pageUrl.Split("/")[-1]

        # Log -log "Fixing Valotabs from page - $pageUrl"
        # Log -log "Resolved page name is $pageName"

        $clientSideComponents = Get-PnPPageComponent -Page $pageName
        # Log -log "Found $($clientSideComponents.Count) components on the page."

        if ($pageUrl -ne $page.Url) {
            $clientPageLayout = "Home"
        } else {
            $clientPage = Get-PnPClientSidePage $pageName
            $clientPageLayout = $clientPage.LayoutType
        }

        # Get the Tabs WebPart instance
        $tabsWPInstances = $clientSideComponents | Where-Object { $_.WebPartId -eq $tabsWebPartId }
        if ($tabsWPInstances.Count -gt 0) {
            Log -log "Found $($tabsWPInstances.Count) instances of the Valo Tabs WebPart on $($pageUrl)."
        }

	}
}

# LogFile 
if ([string]::IsNullOrEmpty(($logFileName))) {
	$logFileName = "Check-ValoTabsWebparts_$([DateTime]::Now.ToString("yyyMMddhhmm")).log";
}

try {
	Log -log "[Check-ValoTabsWebparts]: Start" -level Debug
	$connection = Get-Connection -webUrl $valoHubUrl -credentials $credentials
	
	$site = Get-PnPSite -Includes HubSiteId
	$pages = Search-ValoTabsPages -hubsiteId $site.HubSiteId

	Log -log "Processing results from hubsite, there are $($pages.Count) pages returned by search Url='$valoHubUrl'; HubsiteId=$($site.HubSiteId)"
	Check-TabsWebParts -pages $pages -credentials $credentials

}
catch {
	$errMessage = $_.Exception.Message
    Log -log "Something went wrong. Error='$errMessage'" -level Error
    throw $_
}
finally {
	Log "[Check-ValoTabsWebparts]: Finish" -level Debug
}

