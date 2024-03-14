using namespace System.Management.Automation

Function Send-NotepadMessage {
  Param(
    $ComputerName,
    $Message,
    [ValidateNotNull()]
    [PSCredential]
    [Credential()]
    $Credential = [PSCredential]::Empty
  )
  If ($Credential -ne [PSCredential]::Empty) {
    $SenderFilename = ".\Message from  $Env:USERNAME.txt"
    $SssArgs = @{
      ComputerName = $ComputerName
      Credential = $Credential
    }
    $CmdArgs = @{
      Session = ($Session = New-PSSession @SssArgs)
      Scriptblock = {
        $TaskName = 'RemoteExec-{0}' -f ((New-Guid).Guid -split '\-')[-1]
        $Using:Message > $Using:SenderFilename
        $ActArgs = @{
          Execute = 'notepad.exe'
          Argument = $Using:SenderFilename
          WorkingDirectory = "$PWD"
        }
        $SettingsSet = @{
          MultipleInstances = 'IgnoreNew'
          AllowStartIfOnBatteries = $False
          DontStopIfGoingOnBatteries = $False
          DontStopOnIdleEnd = $False
          StartWhenAvailable = $False
        }
        $RegArgs = @{
          TaskName = $TaskName
          Action = New-ScheduledTaskAction @ActArgs
          Settings = New-ScheduledTaskSettingsSet @SettingsSet
          RunLevel = 'Highest'
        }
        [void] (Register-ScheduledTask @RegArgs -Force)
        Start-ScheduledTask -TaskName $TaskName
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$False
        Remove-Item $Using:SenderFilename -Force
      }
    }
    Invoke-Command @CmdArgs
    Exit-PSSession
    Remove-PSSession $Session
  }
}