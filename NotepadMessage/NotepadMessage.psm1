using namespace System.Management.Automation

Function Send-NotepadMessage {
  <#
  .SYNOPSIS
  Display a message to a remote computer using Notepad.
  .DESCRIPTION
  Send-NotepadMessage diplays a message to a remote computer using Notepad.
  It uses the Task Scheduler to open Notepad window in the Active Session although the commands are run in the Services session.
  .PARAMETER ComputerName
  The IP address or the DNS name of the remote computer.
  .PARAMETER Message
  The message to send.
  .PARAMETER Credential
  The credential to access an account on the remote computer.
  .EXAMPLE
  Send-NotepadMessage -ComputerName dc -Message 'Hello DC!' -Credential (Get-Credential)
  #>
  [CmdletBinding()]
  Param(
    [ValidateNotNullOrWhiteSpace()]
    [string] $ComputerName,
    [string] $Message,
    [ValidateNotNull()]
    [Credential()]
    [PSCredential] $Credential = [PSCredential]::Empty
  )
  # The name of the file to which the message is written.
  $SenderFilename = ".\Message from  $Env:USERNAME.txt"
  Invoke-Command -Scriptblock {
    # Writing the message to the file on the remote computer.
    $Using:Message | Out-File $Using:SenderFilename
    # Set the action to open the file with notepad.
    $TaskAction = New-ScheduledTaskAction -Execute notepad.exe -Argument $Using:SenderFilename -WorkingDirectory $PWD
    # Avoid running multiple instances of the scheduled task at the same time.
    # Set the configuration of the scheduled task.
    $TaskSettings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable
    # Register the task and allow it to run with the highest level.
    $Task = Register-ScheduledTask -TaskName RemoteExec -Action $TaskAction -Settings $TaskSettings -RunLevel Highest -Force
    # Start the task manually. The task does not have a trigger set.
    Start-ScheduledTask -InputObject $Task
    # Clean up.
    Unregister-ScheduledTask -InputObject $Task -Confirm:$False
    Remove-Item $Using:SenderFilename -Force
  } -ComputerName $ComputerName -Credential $Credential
}