<#
This script runs an audit of AD and checks for any accounts that have known bad passwords.

Lithnet AD Password Protection must be enabled and configured on the domain. The DC must have been restarted after the install for this script to work.

Andy Morales
#>
Function Invoke-ADPasswordAudit {
    #Requires -Modules LithnetPasswordProtection

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$NotificationEmail,

        [Parameter(Mandatory = $true)]
        [string]$FromEmail,

        [Parameter(Mandatory = $true)]
        [string]$SMTPRelay
    )

    Import-Module LithnetPasswordProtection

    $CompromisedUsers = @()

    $AllActiveADUsers = Get-ADUser -Filter 'enabled -eq "true"' -Properties PwdLastSet, lastLogonTimeStamp, mail

    #Identify any compromised users
    Foreach ($user in $AllActiveADUsers) {
        if (Test-IsADUserPasswordCompromised -AccountName $user.SamAccountName) {
            $CompromisedUsers += [PSCustomObject]@{
                Name              = $user.Name
                SamAccountName    = $user.SamAccountName
                Mail              = $user.mail
                UserPrincipalName = $user.UserPrincipalName
                PwdLastSet        = [DateTime]::FromFileTimeUtc($user.PwdLastSet).ToShortDateString()
            }
        }
    }

    #Send message if any compromised users are found
    If ($CompromisedUsers.count -gt 0) {
        $EmailBody = $CompromisedUsers | ConvertTo-Html -Fragment -As Table | Out-String

        $SendMailMessageParams = @{
            To         = $NotificationEmail
            From       = $FromEmail
            Subject    = "Bad passwords found on domain $((Get-WmiObject Win32_ComputerSystem).Domain)"
            BodyAsHtml = $EmailBody
            SmtpServer = $SMTPRelay
        }

        Send-MailMessage @SendMailMessageParams
    }
}