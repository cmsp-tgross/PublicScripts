Function Get-LocalAdministrators {
    <#
    Returns members of the local Administrators group.

    Additional filters can be enabled through parameters.

    Andy Morales
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [Bool]$IncludeDisabled,

        [Parameter()]
        [Bool]$ExcludeBuiltInAdministrator,

        [Parameter()]
        [Bool]$LocalAccountsOnly,

        [Parameter()]
        [Bool]$DomainAccountsOnly
    )

    #Get members of the local administrators group using its SID
    $CurrentAdministrators = (Get-WmiObject win32_group -Filter "SID='S-1-5-32-544'").GetRelated()

    $FilteredAccounts = $CurrentAdministrators

    if ($IncludeDisabled) {
        $FilteredAccounts = $CurrentAdministrators | Where-Object { $_.Disabled -eq $true }
    }
    else {
        $FilteredAccounts = $CurrentAdministrators | Where-Object { $_.Disabled -eq $false }
    }

    if ($ExcludeBuiltInAdministrator) {
        $FilteredAccounts = $FilteredAccounts | Where-Object { $_.SID -notlike '*-500' }
    }

    if ($LocalAccountsOnly) {
        $FilteredAccounts = $FilteredAccounts | Where-Object { $_.LocalAccount -eq $true }
    }

    if ($DomainAccountsOnly) {
        $FilteredAccounts = $FilteredAccounts | Where-Object { $_.LocalAccount -eq $false }
    }

    RETURN $FilteredAccounts.Name | Sort-Object
}