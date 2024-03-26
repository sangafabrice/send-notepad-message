using namespace System.Management.Automation

Function Send-NotepadMessage {
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrWhiteSpace()]
    [string] $ComputerName,
    [string] $Message,
    [ValidateNotNull()]
    [Credential()]
    [PSCredential] $Credential = [PSCredential]::Empty
  )
  $SenderFilename = ".\Message from  $Env:USERNAME.txt"
  Invoke-Command -Scriptblock {
    $Using:Message | Out-File $Using:SenderFilename
    $TaskAction = New-ScheduledTaskAction -Execute notepad.exe -Argument $Using:SenderFilename -WorkingDirectory $PWD
    $TaskSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable
    $Task = Register-ScheduledTask -TaskName RemoteExec -Action $TaskAction -Settings $TaskSettings -RunLevel Highest -Force
    Start-ScheduledTask -InputObject $Task
    Unregister-ScheduledTask -InputObject $Task -Confirm:$False
    Remove-Item $Using:SenderFilename -Force
  } -ComputerName $ComputerName -Credential $Credential
}