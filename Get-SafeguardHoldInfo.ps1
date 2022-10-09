#requires -modules FU.WhyAmIBlocked

#Run this on the client to pull the appraiser db info and client safeguard hold IDs.
#Or run CMPivot to pull this info from the registry

#CMPIVOT Query
<#
Registry('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\*') | where Property == 'GatedBlockId' and Value != '' and Value != 'None'
| join kind=inner (
		Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OneSettings\compat\appraiser\*') 
		| where Property == 'ALTERNATEDATALINK')
| join kind=inner (
		Registry('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OneSettings\compat\appraiser\*') 
		| where Property == 'ALTERNATEDATAVERSION')
| project Device,GatedBlockID=Value,ALTERNATEDATALINK=Value1,ALTERNATEDATAVERSION=Value2
#>

function Get-ClientSafeguardHoldInfo {
    param(
        [parameter(mandatory = $true)]
        [string]$OS
    )
    try {
        $SettingsKey = Get-Item -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OneSettings\compat\appraiser\Settings"
        $TargetVersionUpgradeExperienceIndicatorsKeys = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq $OS }
        $Settings = @{
            ALTERNATEDATALINK    = $SettingsKey | Get-ItemPropertyValue -Name "ALTERNATEDATALINK"
            ALTERNATEDATAVERSION = $SettingsKey | Get-ItemPropertyValue -Name "ALTERNATEDATAVERSION"
            GatedBlockId         = ($TargetVersionUpgradeExperienceIndicatorsKeys | Get-ItemProperty -Name "GatedBlockId" -ErrorAction SilentlyContinue).GatedBlockId
        }

        return $Settings
    }
    catch {
        throw $_
    }
}

#Pass in client info to get details
function Get-SafeGuardHoldDetails {
    Param (
        [parameter(Mandatory = $true)]
        [string]$AppraiserURL,
        
        [parameter(Mandatory = $true)]
        [int]$AppraiserVersion,

        [parameter(Mandatory = $false)]
        [string[]]$SafeGuardHoldId,

        $Path = "C:\Temp"
    )

    $AppriaserRoot = $Path

    $ExistingXML = Get-ChildItem -Path $AppriaserRoot\*.xml -Recurse -File | Where-Object { $_.Name -like "*$ALTERNATEDATAVERSION*" } -ErrorAction SilentlyContinue

    if (-Not $ExistingXML) {
        $LinkParts = $ALTERNATEDATALINK.Split("/")
        $OutFileName = "$($ALTERNATEDATAVERSION)_$($LinkParts[$LinkParts.Count-1])"
        $OutFilePath = "$AppriaserRoot\AppraiserData"

        if (-not (Test-Path $OutFilePath)) {
            New-Item -Path $OutFilePath -ItemType Directory -Force -ErrorAction SilentlyContinue
        }
        
        Invoke-WebRequest -URI $ALTERNATEDATALINK -OutFile "$OutFilePath\$OutFileName"
    
        Export-FUXMLFromSDB -AlternateSourcePath $OutFilePath -Path $AppriaserRoot
        $ExistingXML = Get-ChildItem -Path $AppriaserRoot\*.xml -Recurse -File | Where-Object { $_.Name -like "*$ALTERNATEDATAVERSION*" } -ErrorAction SilentlyContinue
    }

    $DBBlocks = if ($ExistingXML) {
        [xml]$Content = Get-Content -Path $ExistingXML -Raw

        $OSUpgrade = $Content.SelectNodes("//SDB/DATABASE/OS_UPGRADE")
        $GatedBlockOSU = $OSUpgrade | Where-Object { $_.DATA.Data_String.'#text' -eq 'GatedBlock' } 
    
        $GatedBlockOSU | ForEach-Object {
            @{
                AppName       = $_.App_Name.'#text'
                BlockType     = $_.Data[0].Data_String.'#text'
                SafeguardId   = $_.Data[1].Data_String.'#text'
                NAME          = $_.NAME.'#text'
                APP_NAME      = $_.APP_NAME.'#text'
                VENDOR        = $_.VENDOR.'#text'
                EXE_ID        = $_.EXE_ID.'#text'
                DEST_OS_GTE   = $_.DEST_OS_GTE.'#text'
                DEST_OS_LT    = $_.DEST_OS_LT.'#text'
                MATCHING_FILE = $_.MATCHING_FILE.'#text'
                PICK_ONE      = $_.PICK_ONE.'#text'
                INNERXML      = $_.InnerXML
            }
        }
    
        $MIB = $Content.SelectNodes("//SDB/DATABASE/MATCHING_INFO_BLOCK")
        $GatedBlockMIB = $MIB | Where-Object { $_.DATA.Data_String.'#text' -eq 'GatedBlock' }
        $GatedBlockMIB | ForEach-Object {
            @{
                AppName         = $_.App_Name.'#text'
                BlockType       = $_.Data[0].Data_String.'#text'
                SafeguardId     = $_.Data[1].Data_String.'#text'
                APP_NAME        = $_.APP_NAME.'#text'
                DEST_OS_GTE     = $_.DEST_OS_GTE.'#text'
                DEST_OS_LT      = $_.DEST_OS_LT.'#text'
                EXE_ID          = $_.EXE_ID.'#text'
                MATCH_PLUGIN    = $_.MATCH_PLUGIN.Name.'#text'
                MATCHING_DEVICE = $_.MATCHING_DEVICE.Name.'#text'
                MATCHING_REG    = $_.MATCHING_REG.Name.'#text'
                NAME            = $_.NAME.'#text'
                PICK_ONE        = $_.PICK_ONE.Name.'#text'
                SOURCE_OS_LTE   = $_.SOURCE_OS_LTE.'#text'
                VENDOR          = $_.VENDOR.'#text'
                INNERXML        = $_.InnerXML
            }
        }
    } Select-Object -Unique * | Sort-Object AppName


    if ($SafeGuardHoldId) {
        $DBBlocks | Where-Object { $_.SafeguardId -in $SafeGuardHoldId } | ForEach-Object { [PSCustomObject]$_ }
    }
    else {
        $DBBlocks | ForEach-Object { [PSCustomObject]$_ }
    }
}

$Settings = Get-ClientSafeguardHoldInfo -OS "NI22H2"

#Run this with a list of ids to get specific entries
Get-SafeGuardHoldDetails -AppraiserURL $Settings.ALTERNATEDATALINK -AppraiserVersion $Settings.ALTERNATEDATAVERSION -SafeGuardHoldId $Settings.GatedBlockId 

#Run this with no ids to list all safeguard holds from the appraiser db
Get-SafeGuardHoldDetails -AppraiserURL $Settings.ALTERNATEDATALINK -AppraiserVersion $Settings.ALTERNATEDATAVERSION