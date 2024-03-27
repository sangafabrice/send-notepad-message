# The function NotepadMessage module should not be loaded twice.
Import-Module '.\NotepadMessage' -NoClobber
# Restart the UI every time this script is executed.
Import-Module '.\NotepadMessage.UI' -Force

$SendButton.add_Click({
  # Disable the form when the user clicks to avoid multiple messages.
  $SendButton.Enabled = $False
  $ComputerNameTextBox.Enabled = $False
  $UsernameTextBox.Enabled = $False
  $PasswordTextBox.Enabled = $False
  $MessageTextBox.Enabled = $False
  # The Notepad message arguments.
  $NoteMgeArgs = @{
    ComputerName = $ComputerNameTextBox.Text
    Message      = $MessageTextBox.Text
    Credential   = [System.Management.Automation.PSCredential]::New(
      $UsernameTextBox.Text,
      # Secure the password string.
      ($PasswordTextBox.Text | ConvertTo-SecureString -AsPlainText -Force)
    )
  }
  # Redirect Errors to SendError to handle it.
  $SendError = Send-NotepadMessage @NoteMgeArgs 2>&1
  $SendError.Exception.Message | Out-Host 
  # Enable the form when text fields.
  $ComputerNameTextBox.Enabled = $True
  $UsernameTextBox.Enabled = $True
  $PasswordTextBox.Enabled = $True
  $MessageTextBox.Enabled = $True
  # Delay enabling the Send button field by 5 seconds.
  $TimeTick = 5
  # If there is an error, bypass the timer.
  While ((-not $SendError) -and $TimeTick -gt 0) {
    $SendButton.Text = 'Send ({0})' -f $TimeTick--
    Start-Sleep -Seconds 1
  }
  $SendButton.Text = 'Send'
  $SendButton.Enabled = $True
})
[void] $SenderDialog.ShowDialog()
$SenderDialog.Dispose()