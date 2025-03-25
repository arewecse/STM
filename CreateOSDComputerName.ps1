<# Gary Blok @gwblok
Generate Generic Computer Name based on Model Name... doesn't work well in Production as it names the machine after the model, so if you have more than one model.. it will get the same name.
This is used in my lab to name the PCs after the model, which makes life easier for me.

It creates randomly generated names for VMs following the the pattern "VM-CompanyName-Random 5 digit Number" - You would need to change how many digits this is if you have a longer company name.

NOTES.. Computer name can NOT be longer than 15 charaters.  There is no checking to ensure the name is under that limit.


#>

try {
    $tsenv = new-object -comobject Microsoft.SMS.TSEnvironment
}
catch{
    #Write-Output "Not in TS"
}

function Build-ComputerName {
    [CmdletBinding()]
    param(
        [switch]$Apply
    )

    $ComputerSystem = Get-Ciminstance -ClassName Win32_ComputerSystem
    $Manufacturer = $ComputerSystem.Manufacturer
    $Model = $ComputerSystem.Model
    $CompanyName = "Stratum"
    $Serial = (Get-WmiObject -class:win32_bios).SerialNumber
    
	if ($Manufacturer -match "Microsoft"){
        if ($Model -match "Virtual"){
            $Random = Get-Random -Maximum 99999
            $ComputerName = "VM-$($Random )"
            if ($ComputerName.Length -gt 15){
                $ComputerName = $ComputerName.Substring(0,15)
            }
        }
    }

    else {
        if ($Serial.Length -ge 15){
            $ComputerName = $Serial.substring(0,15)
        }
        else{
            $ComputerName = $Serial 
        }
    }
    if ($ComputerName.Length -gt 15){
        Write-Output "-------------------------------------------------------------------------------------------------------------------------------"
        Write-Output "Computer Name is too long, can only be 15 characters."
        Write-Output "Current Computer name is set to: $ComputerName, trimming to....."
        $ComputerName = $ComputerName.Substring(0,15)
        Write-Output "New Name = $ComputerName"
        Write-Output "Your LOGIC Failed, you need to see why it was coming up longer than 15, so you can fix it, instead of having it use the bandaid"
        Write-Output "-------------------------------------------------------------------------------------------------------------------------------"
    }
    if ($Apply){
        rename-computer -NewName $ComputerName -Force -Verbose
    }
    return $ComputerName
}
if ($tsenv){
    $ComputerName = Build-ComputerName
    Write-Output "====================================================="
    Write-Output "Setting OSDComputerName to $ComputerName"
    $tsenv.value('OSDComputerName') = $ComputerName
    Write-Output "====================================================="
}
