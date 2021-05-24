<#
This script searches for WMI subscriptions that might contain entires used for persistence.

.LINK
https://pentestlab.blog/2020/01/21/persistence-wmi-event-subscription/
#>

$ClassNames = @(
    '__EventFilter',
    '__FilterToConsumerBinding',
    '__EventConsumer',
    'CommandLineEventConsumer'
)

$WmiSubs = @()

Foreach ($class in $ClassNames) {
    $WmiSubs += Get-WmiObject -Namespace root\Subscription -Class $class
}

$SuspiciousSubFound = $false
$SuspiciousSubs = @()

foreach ($sub in $WmiSubs) {
    if ($sub.CommandLineTemplate -like '*powershell*') {
        $SuspiciousSubFound = $true
        $SuspiciousSubs += $sub
    }
}

if ($SuspiciousSubFound) {
    Write-Output 'SuspiciousSubsFound'
    Write-Output $SuspiciousSubs | Select-Object Name, CommandLineTemplate
}
else{
    Write-Output 'NothingFound'
}