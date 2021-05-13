<#

This script is intended to help prevent ransomware attacks where it does not infect a computer if the RU keyboard layout is in use.

This will not replace the default, but rather add a second keyboard.

The script will run through all the currently signed in users and add RU as second keyboard. Users will need to sign out for the change to take effect. Running the script repeatedly is recommended.

Andy Morales
#>

$NewLanguageCode = '00000419'

#only get reg keys belonging to signed in users
$UserKeys = Get-ChildItem -Path registry::HKEY_USERS | Where-Object { $_.name.Length -eq 57 }

:userKeys Foreach ($User in $UserKeys) {

    $CurrentLangs = Get-Item -Path "registry::$($user.name)\Keyboard Layout\Preload" | Select-Object -ExpandProperty Property | Where-Object { $_.Length -eq 1 }

    Foreach ($lang in $CurrentLangs) {
        if ((Get-ItemProperty -Path "registry::$($user.name)\Keyboard Layout\Preload" -Name $lang).$lang -eq $NewLanguageCode) {

            Write-Output "Lang is already installed for $($user.name)."
            Continue userKeys

        }
    }

    $HighestLangNumber = ($CurrentLangs | Measure-Object -Maximum).Maximum

    $NewLangNumber = $HighestLangNumber + 1

    Set-ItemProperty -Path "registry::$($user.name)\Keyboard Layout\Preload" -Name $NewLangNumber -Value $NewLanguageCode -Type String

}