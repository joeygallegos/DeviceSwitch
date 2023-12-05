
# Randomly the driver gets a number prepended to the device name, so we're adding a wildcard
$TelevisionDriver = "*SAMSUNG*NVIDIA High Definition Audio*"
$HeadsetDriver = "*PRO X Wireless Gaming Headset*"

# Install the AudioDeviceCmdlets module if not already installed
if (-not (Get-Module -Name AudioDeviceCmdlets -ListAvailable)) {
    Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force
}

# Import the AudioDeviceCmdlets module
Import-Module -Name AudioDeviceCmdlets

# For message box
Add-Type -AssemblyName PresentationFramework
Import-Module BurntToast

# Get list of Audio Devices and filter by Playback and Default
$CurrentDevice = Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object Default -eq $true

Write-Host "CURRENT DEVICE:"
Write-Host $CurrentDevice.Name

if ($CurrentDevice -eq $null) {
    Write-Host "The current audio output device is not Device1 or Device2 (not TV or Headset)."
    [System.Windows.MessageBox]::Show('The current audio output device is not TV or Headset', 'DeviceSwitchUtil', 'Ok', 'Error')
}
else {
    $DesiredDevicePrettyName = "";
    if ($CurrentDevice.Name -like "*$TelevisionDriver*") {
        # Switch to HeadsetDriver
        $DesiredDevice = Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object Name -like "*$HeadsetDriver*"
        $DesiredDevicePrettyName = "Headset"
    }
    else {
        # Switch to TelevisionDriver
        $DesiredDevice = Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object Name -like "*$TelevisionDriver*"
        $DesiredDevicePrettyName = "TV"
    }

    if ($DesiredDevice -eq $null) {
        Write-Host "The desired audio output device '$($DesiredDevice.Name)' known as '$($DesiredDevicePrettyName)' was not found. Check if the device names are correct and showing in the Powershell query."
        [System.Windows.MessageBox]::Show("The desired audio output device '$($DesiredDevice.Name)' known as '$($DesiredDevicePrettyName)' was not found. Check if the device names are correct and showing in the Powershell query.", 'DeviceSwitchUtil', 'Ok', 'Error')
    }
    else {
        # Set the desired device as the default audio output device
        Set-AudioDevice -ID $DesiredDevice.ID
        Write-Host "Audio output device changed to '$($DesiredDevice.Name)'."
        New-BurntToastNotification -Text "Audio output device changed to '$($DesiredDevicePrettyName)'." -Sound "SMS" -AppLogo C:\none.jpg
    }
}
