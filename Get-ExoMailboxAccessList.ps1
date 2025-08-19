
# Get-ExoMailboxAccessList.ps1

<#PSScriptInfo

.VERSION 1.0

.GUID d5af688e-79dc-4817-a81c-6820b29b40a4

.AUTHOR June Castillote

.COMPANYNAME

.COPYRIGHT June Castillote

.TAGS Exchange, Exchange Online, PowerShell, ExchangeOnlineManagement, Mailbox Permission, Permission, Full Access, FullAccess, Send As, SendAs, SendOnBehalf, Send On Behalf

.LICENSEURI https://github.com/junecastillote/Get-ExoMailboxAccessList/blob/main/LICENSE

.PROJECTURI https://github.com/junecastillote/Get-ExoMailboxAccess

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>


<#
.SYNOPSIS
    PowerShell script to extract FullAccess, SendAs, and SendonBehalf access list to Exchange Online Mailboxes
.DESCRIPTION
    This script leverages the Exchange Online PowerShell module to extract the access list of one or more or all mailboxes.
    The output can be returned to the console output as object and/or exported to a CSV file.
.NOTES

.LINK
    https://github.com/junecastillote/Get-ExoMailboxAccess
.EXAMPLE
    .\Get-ExoMailboxAccessList.ps1 -MailboxId "Adam Smith"

    Get the mailbox access list for the "Adam Smith" mailbox. The result is displayed on the screen.

.EXAMPLE
    "Adam Smith","Homer@poshlab.xyz" | .\Get-ExoMailboxAccessList.ps1 -OutputCsv .\result.csv

    Get the mailbox access list for multiple mailboxes through the pipeline. The result is exported to the .\result.csv file.

.EXAMPLE
    Get-Mailbox -RecipientTypeDetails -ResultSize Unlimited | .\Get-ExoMailboxAccessList.ps1 -OutputCsv .\sharedMailboxAccess.csv

    Get the mailbox access list for all shared mailbox. The result is exported to the .\sharedMailboxAccess.csv file.

#>

#Requires -Modules @{ ModuleName="ExchangeOnlineManagement"; ModuleVersion="3.7.0" }

[CmdletBinding()]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias(
        "GUID", "Name", "Identity", "PrimarySmtpAddress", "UserPrincipalName", "DistinguishedName",
        "LegacyExchangeDN", "SamAccountName", "Alias", "ExchangeGuid"
    )]
    [ValidateNotNullOrEmpty()]
    [string]$MailboxId,

    [Parameter()]
    [string]$OutputCsv,

    [Parameter()]
    [switch]
    $Append,

    [Parameter()]
    [switch]$ReturnResult
)

begin {
    $scriptStart = [System.Diagnostics.Stopwatch]::StartNew()

    $result = [System.Collections.Generic.List[object]]::new()

    $counter = 0

    $exoConnected = Get-ConnectionInformation
    if (-not $exoConnected) {
        Write-Error "Exchange Online PowerShell is not connected."
        if ($MyInvocation.InvocationName -like '*.ps1') {
            exit 1
        }
        else {
            throw "Exchange Online PowerShell is not connected."
        }
        break
    }

    if (-not $OutputCsv -and -not $ReturnResult) {
        Write-Verbose "Both -OutputCsv and -ReturnResult are not used. Enabling -ReturnResult by default."
        $ReturnResult = $true
    }

    if ($OutputCsv -and (Test-Path $OutputCsv) -and -not $Append) {
        Write-Verbose "The output file [$OutputCsv)] already exists and will be overwritten."
        Remove-Item $OutputCsv -Force -Confirm:$false
    }

    if ($OutputCsv -and (Test-Path $OutputCsv) -and $Append) {
        Write-Verbose "The output file [$OutputCsv)] already exists and new results will be appended."
    }

}

process {

    $fullAccess_permission = @()
    $sendAs_permission = @()
    $sendOnBehalf_permission = @()

    $counter++

    $mailbox = ""

    try {
        $mailbox = Get-Mailbox -Identity $MailboxId -IncludeGrantSendOnBehalfToWithDisplayNames -ErrorAction Stop
    }
    catch {
        Write-Error -ErrorRecord $_
        return  # skip this identity, keep processing pipeline
    }

    if ($mailbox.GrantSendOnBehalfTo -and (-not $mailbox.GrantSendOnBehalfToWithDisplayNames)) {
        Write-Debug "Getting GrantSendOnBehalfToWithDisplayNames"
        $mailbox = Get-Mailbox -Identity $MailboxId -ErrorAction Stop -IncludeGrantSendOnBehalfToWithDisplayNames
    }

    Write-Debug "Done getting mailbox."

    Write-Verbose "Processing [#$($counter)] Type: [$($mailbox.RecipientTypeDetails)] | Name: [$($mailbox.DisplayName) / $($mailbox.PrimarySmtpAddress)]"

    $fullAccess_permission += (Get-MailboxPermission -Identity $mailbox | Where-Object { `
                !$_.Inherited -and `
                !$_.Deny -and `
                !$_.IsOwner -and `
                $_.User -ne 'NT AUTHORITY\SELF' -and `
                $_.AccessRights -contains 'FullAccess'
        })

    $sendAs_permission += (
        Get-RecipientPermission -Identity $mailbox -AccessRights SendAs | Where-Object {`
                !$_.Inherited -and `
                $_.Trustee -ne 'NT AUTHORITY\SELF' -and `
                $_.Trustee -notlike "S-*" -and `
                $_.AccessControlType -eq 'Allow'
        }
    )

    if ($mailbox.GrantSendOnBehalfTo) {
        $sendOnBehalf_permission += $(
            $mailbox.GrantSendOnBehalfToWithDisplayNames | ForEach-Object {
                [string](($_ -split ", ")[0]).Replace('(', '').Replace(')', '')
            }
        )
    }

    $result.Add(
        [PSCustomObject]@{
            Mailbox      = $mailbox.DisplayName
            Email        = $mailbox.PrimarySmtpAddress
            FullAccess   = ($fullAccess_permission.User -join ", ")
            SendAs       = ($sendAs_permission.Trustee -join ", ")
            SendOnBehalf = ($sendOnBehalf_permission -join ", ")
        }
    )
}

end {

    if ($OutputCsv) {
        $result | Export-Csv -NoTypeInformation -Path $OutputCsv -Append:$Append
        Write-Verbose "Results saved to [$((Resolve-Path $OutputCsv).Path)]"
    }

    if ($ReturnResult) {
        $result
    }

    $scriptStart.Stop()

    Write-Verbose ("Total script time: {0:N2} seconds" -f $scriptStart.Elapsed.TotalSeconds)
}


