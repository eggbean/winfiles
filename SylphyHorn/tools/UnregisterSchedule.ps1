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
    Unregister-ScheduledTask -TaskName "SylphyHorn Startup" -Confirm:$false
}
