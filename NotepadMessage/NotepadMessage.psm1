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
  If ($Credential -eq [PSCredential]::Empty) {
    Return
  }
  $SenderFilename = ".\Message from  $Env:USERNAME.txt"
  $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential
  Invoke-Command -Session $Session -Scriptblock {
    $TaskName = "RemoteExec-$(New-Guid)"
    $Using:Message | Out-File $Using:SenderFilename
    $TaskAction = New-ScheduledTaskAction -Execute notepad.exe -Argument $Using:SenderFilename -WorkingDirectory $PWD
    $TaskSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable
    [void] (Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Settings $TaskSettings -RunLevel Highest -Force)
    Start-ScheduledTask -TaskName $TaskName
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$False
    Remove-Item $Using:SenderFilename -Force
  }
  Remove-PSSession $Session
}