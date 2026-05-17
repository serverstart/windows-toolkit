[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$StorageAccountName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$ProfileShareName
)

###################
#    Variables    #
###################

$FileServer="$($StorageAccountName).file.core.windows.net"
$ProfilePath="\\$($FileServer)\$($ProfileShareName)"

##################################
#    Configure FSLogix Profile   #
##################################

# Source: https://blog.itprocloud.de/Using-FSLogix-file-shares-with-Azure-AD-cloud-identities-in-Azure-Virtual-Desktop-AVD/

Write-Host "serverstart - Configure FSLogix : Configure FSLogix Profile Settings"

# Create Profiles Path
New-Item -Path "HKLM:\SOFTWARE" -Name "FSLogix" -ErrorAction Ignore
New-Item -Path "HKLM:\SOFTWARE\FSLogix" -Name "Profiles" -ErrorAction Ignore


# Apply new settings to profiles path4
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "Enabled" -Value 1 -force
Remove-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -ErrorAction Ignore
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name "VHDLocations" -Value "$ProfilePath" -PropertyType MultiString -force


Write-Host "serverstart - Configure FSLogix : Done configuring FSLogix Profile Settings"