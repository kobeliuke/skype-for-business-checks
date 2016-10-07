function Read-Registry($registryHive, $key, $propertyName) {
    $value= ""

    $localKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($registryHive, [Microsoft.Win32.RegistryView]::Registry64)
    $localKey = $localKey.OpenSubKey($key)
    if ($localKey -ne $null) {
        $value = $localKey.GetValue($propertyName).ToString()
        return $value
    }

    $localKey32 = [Microsoft.Win32.RegistryKey]::OpenBaseKey($registryHive, [Microsoft.Win32.RegistryView]::Registry32)
    $localKey32 = $localKey32.OpenSubKey($key)
    if ($localKey32 -ne $null) {
        $value = $localKey32.GetValue($propertyName).ToString()
        return $value
    }

    return $value
}

function Get-SkypeForBusinessRegistryKeys {
    $lync2013Key = "SOFTWARE\\Microsoft\\Office\\15.0\\Registration\\{0EA305CE-B708-4D79-8087-D636AB0F1A4D}"
    $office2013Key = "SOFTWARE\\Microsoft\\Office\\15.0\\Common\\ProductVersion"

    return [System.Tuple]::Create($lync2013Key, $office2013Key);
}

function Check-SkypeSDKPrerequisites($keys) {
    $lync2013Value = Read-Registry ([Microsoft.Win32.RegistryHive]::LocalMachine) $keys.Item1 "ProductName"
	$office2013Value = Read-Registry ([Microsoft.Win32.RegistryHive]::LocalMachine) $keys.Item2 "LastProduct"
	if (($lync2013Value -eq $null) -Or ($office2013Value -eq $null)) {
		throw New-Object System.InvalidOperationException("Lync 2013 retrieved or Office 2013 SP1 not installed")
	}

	if (($lync2013Value -ne "Microsoft Lync 2013") -Or ($office2013Value -ne "15.0.4569.1506")) {
		throw New-Object System.InvalidOperationException("Lync 2013 retrieved: {lync2013Value} - Expected : Microsoft Lync 2013 {vbCrLf} Office 2013 version retrieved: {office2013Value} - Expected : 15.0.4569.1506");
	}
}

function CheckForSkypeForBusiness2016() {
    $lync2016Key = "SOFTWARE\\Microsoft\\Office\\16.0\\Registration\\{03CA3B9A-0869-4749-8988-3CBC9D9F51BB}"
    $lync2016Value = Read-Registry ([Microsoft.Win32.RegistryHive]::LocalMachine) $lync2016Key "ProductName"
    if ($lync2016Value -ne "Skype for Business 2016") {
        return
    }

    $office2016LyncUISuppressionModeKey = "Software\\Microsoft\\Office\\16.0\\Lync"
    $office2016LyncUISuppressionModeValue = Read-Registry ([Microsoft.Win32.RegistryHive]::CurrentUser) $office2016LyncUISuppressionModeKey "UISuppressionMode"

		if ($office2016LyncUISuppressionModeValue -ne "1") {
			throw New-Object System.InvalidOperationException("Skype for Business client 2016 has been detected and is not setup to run in UISuppressionMode. Please run the script under support\\skype for business.")
		}
	}

 function CheckLyncForBusinessIsSetupInUISuppressionMode() {
    $office2013LyncUISuppressionModeKey = "Software\\Microsoft\\Office\\15.0\\Lync"
    $office2013LyncUISuppressionModeValue = Read-Registry ([Microsoft.Win32.RegistryHive]::CurrentUser) $office2013LyncUISuppressionModeKey, "UISuppressionMode"

		if (($office2013LyncUISuppressionModeValue -eq $null) -Or ($office2013LyncUISuppressionModeValue.Equals -ne "1")) {
			throw New-Object System.InvalidOperationException("Skype for Business client is not setup to run in UISuppressionMode. Please run the script under support\\skype for business.");
		}
	}


$keys = GetS4BRegistryKeys
#Check-SkypeSDKPrerequisites($keys);
CheckForSkypeForBusiness2016



