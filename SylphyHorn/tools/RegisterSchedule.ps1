#
# Is Running the script as administrator?
#
function Is-RunAsAdmin
{
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

#
# Run the script as administrator
# 
function Start-ScriptAsAdmin
{
    param(
        [string]
        $ScriptPath,
        [object[]]
        $ArgumentList
    )
    # Not administrator
    if(!(Is-RunAsAdmin))
    {
        # Generate command from script path and arguments
        $list = @($ScriptPath)
        if($null -ne $ArgumentList)
        {
             $list += @($ArgumentList)
        }
        # Run again
        Start-Process powershell -ArgumentList $list -Verb RunAs -Wait
    }
}

Start-ScriptAsAdmin -ScriptPath $PSCommandPath
if(Is-RunAsAdmin)
{
    $dirPath = (Convert-Path ../)
    $path = '"' + $dirPath + '\SylphyHorn.exe"'
    $trigger = New-ScheduledTaskTrigger -AtLogon
    $action = New-ScheduledTaskAction -Execute $path
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8
    $settings.DisallowStartIfOnBatteries = $false
    Register-ScheduledTask -TaskName "SylphyHorn Startup" -RunLevel Highest -Trigger $trigger -Action $action -Settings $settings -Force
}
