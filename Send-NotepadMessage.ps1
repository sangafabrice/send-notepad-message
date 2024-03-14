Import-Module '.\NotepadMessage' -NoClobber
Import-Module '.\NotepadMessage.UI' -Force

$SendButton.add_Click({
  $SendButton.Enabled = $False
  $ComputerNameTextBox.Enabled = $False
  $UsernameTextBox.Enabled = $False
  $PasswordTextBox.Enabled = $False
  $MessageTextBox.Enabled = $False
  $NoteMgeArgs = @{
    ComputerName = $ComputerNameTextBox.Text
    Message      = $MessageTextBox.Text
    Credential   = [System.Management.Automation.PSCredential]::New(
      $UsernameTextBox.Text,
      ($PasswordTextBox.Text | ConvertTo-SecureString -AsPlainText -Force)
    )
  }
  $SendError = Send-NotepadMessage @NoteMgeArgs 2>&1
  $SendError.Exception.Message | Out-Host 
  $ComputerNameTextBox.Enabled = $True
  $UsernameTextBox.Enabled = $True
  $PasswordTextBox.Enabled = $True
  $MessageTextBox.Enabled = $True
  $TimeTick = 5
  While ((-not $SendError) -and $TimeTick -gt 0) {
    $SendButton.Text = 'Send ({0})' -f $TimeTick--
    Start-Sleep -Seconds 1
  }
  $SendButton.Text = 'Send'
  $SendButton.Enabled = $True
})
[void] $SenderDialog.ShowDialog()
$SenderDialog.Dispose()