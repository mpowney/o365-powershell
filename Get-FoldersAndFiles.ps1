Param (
    [string] $Url,
    [switch] $UseWebLogin,
    [string] $DocumentLibrary
)

Connect-PnPOnline -Url $Url -UseWebLogin:$UseWebLogin

$global:List = Get-PnPList $DocumentLibrary

$global:RootFolder = $List.RootFolder


