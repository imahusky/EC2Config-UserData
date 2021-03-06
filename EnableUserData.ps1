#This script automatically enables UserData execution on the selected offline disk

#Desired UserData plugin state
$UserDataSetting = "Enabled"

#Set Path constant
$preFilePath = ":\Program Files\Amazon\Ec2ConfigService\Settings\config.xml"

#Display drive letters of all non-root partitions >= 8GB
Write-Host `n`n"Drive letters that can be modified:"

foreach ($_ in (Get-Partition | where {$_.DiskNumber -ne '0' -and $_.Size -gt 7.99GB -and (Test-Path ($_.DriveLetter.ToString() + $preFilePath))})) {"-----> " + $_.DriveLetter + ":"}

#Get drive letter from user
$driveLetter = Read-Host 'What is the drive letter of the disk to be modified?'

#Add drive letter to complete path to config file
$filePath = $driveLetter + $preFilePath

if (Test-Path $filePath)
	{
	#Read content of config.xml file
	$xml = [xml] (Get-Content $filePath)

	#Update UserData plugin state
	$node = $xml.Ec2ConfigurationSettings.Plugins.Plugin | Where {$_.Name -eq 'Ec2HandleUserData'}

	$node.State = $UserDataSetting

	#Save the changes to the xml file
	$xml.Save($filePath)

	#Validate change. Provide instructions, if setting wasn't updated.
	$checkXml = [xml] (Get-Content $filePath)

	if (($checkXml.Ec2ConfigurationSettings.Plugins.Plugin | Where {$_.Name -eq 'Ec2HandleUserData'}).State -eq 'Enabled')
	    {
	    Write-Host "All Done!!";
	    Write-Host "Operation successful. Please close this window, take the disk offline, and attach it back to the original instance as /dev/sda1.";
	    }
	else 
	    {
	    Write-Host "OOPS! Something went wrong! Please double-check the partition you selected, to ensure you're selecting the correct one.";
	    Write-Host "Also, please ensure that you're running this script as an Admin.";
	    Write-Host "Otherwise, please manually set the 'Ec2HandleUserData' state to 'Enabled' in "$filePath;
	    Write-Host "Or contact AWS Support for assistance.";
	    }
	    }
else
	{
	Write-Host `n"OOPS! "$filePath" does *NOT* exist on the partition specified. Please ensure that you've connected the correct volume and selected the correct partition. Then, run this script again." `n
	Write-Host "If you continue to experience this error, please conact AWS Support for assistance." `n
	}
