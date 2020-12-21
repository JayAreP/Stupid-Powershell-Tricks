

# Working with object parameters and exports. 
Create a configuration object and write it to a file. 

In this case, we are going to ask (via params) for:
* `hostName` Name of the host
* `hostUser` Username 
* `hostPass` Password as a secure string
* `hostOS` the OS of the host. 

The object will then be built and saved to a clixml file named for the host. Of course you can simply save this in whatever manner you prefer. 

`function createHost`
```powershell
function createHost {
    # Ask for parameters here, use the examples for working with secure strings as well as validate sets. 
    param(
        [parameter(Mandatory)]
        [string] $hostName,
        [parameter(Mandatory)]
        [string] $hostUser,
        [parameter(Mandatory)]
        [string] $hostPass,
        [parameter(Mandatory)]
        [ValidateSet('Linux','Windows','ESX',IgnoreCase = $false)]
        [string] $hostOS
    )

    # Create the credential object
    $secureHostPass = $hostPass | ConvertTo-SecureString -AsPlainText -Force
    $credential = [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($hostUser, $secureHostPass)

    # Build a powershell object (psobject)
    $o = New-Object psobject
    $o | Add-Member -MemberType NoteProperty -Name 'credential' -Value $credential
    $o | Add-Member -MemberType NoteProperty -Name 'Hostname' -Value $hostName
    $o | Add-Member -MemberType NoteProperty -Name 'OS' -Value $hostOS

    # Create a filename to be used
    $filename = $hostName + '.xml'

    # Export the object to the above file name. 
    $o | Export-Clixml -Path $filename
    return $o
}
```

Run this script like:
```powershell
createHost -hostName TestHost1 -hostUser root -hostPass 'password' -hostOS Linux
```

# Import this configuraiton later on. 
You would then import this as an array later via:

`function readHost`
```powershell
function readHost {
    # Ask for the host object
    param(
        [parameter(Mandatory)]
        [string] $hostName
    )

    ## Import the clixml
    $filename = $hostName + '.xml'

    # read the config
    $hostConfig = Import-Clixml $filename

    # return the config
    return $hostConfig
}
```

You would use this to store the configuration to a usable variable like so:
```powershell
$hostconfig = readHost -hostName TestHost1
```

You can also prompt for any of this information to be entered by the operrator using simple syntax like:
```powershell
[string] $hostUser = Read-Host -Prompt "Enter the username"
```

Or indeed force a secure string prompt to mask the password like so:
```powershell
[string] $hostPass = Read-Host -Prompt "Enter the password" -AsSecureString
```
