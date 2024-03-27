<#
.SYNOPSIS
Creates a new NotepadMessage Windows form.
#>
using namespace System.Windows.Forms
using namespace System.Drawing

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$SenderDialog = [Form]::New() | ForEach-Object {
  $_.Size = '400, 650'
  $_.Text = 'Notepad Message'
  $_.Icon = [Icon]::New("$PSScriptRoot\ui.ico")
  $_.Font = 'Segoe UI,14'
  $_.StartPosition = 'CenterScreen'
  $_.MinimumSize = $_.Size
  $_.MaximumSize = $_.Size
  Return $_
}
$SenderDialog.Controls.AddRange(@(
  ($ComputerNameTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 359
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 41"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Computer name:'
    $_.Location = '10, 15'
    Return $_
  }
  ($UsernameTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 359
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 106"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Username:'
    $_.Location = '10, 80'
    Return $_
  }
  ($PasswordTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 359
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 171"
    $_.Text = '';
    $_.PasswordChar = '*';
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Password:'
    $_.Location = '10, 145'
    Return $_
  }
  ($MessageTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 359
    $_.Height = 200
    $_.BorderStyle = 'FixedSingle'
    $_.Multiline = $True
    $_.Location = "12, 341"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Message:'
    $_.Location = '10, 315'
    Return $_
  }
  ($SendButton = [Button]::new() | ForEach-Object {
    $_.Width = 359
    $_.Text = 'Send'
    $_.AutoSize = $True
    $_.FlatStyle = 'Flat'
    $_.Location = '12, 555'
    Return $_
  })
))

Function Set-SendButtonEnabled {
  <#
  .SYNOPSIS
  Set the Send button active state.
  .DESCRIPTION
  Set-SendButtonEnabled disables the Send button if one of the header fields of the Notepad message is empty.
  #>
  [CmdletBinding()]
  Param()
  If (
    [string]::IsNullOrWhiteSpace($Script:ComputerNameTextBox.Text) -or
    [string]::IsNullOrWhiteSpace($Script:UsernameTextBox.Text) -or
    [string]::IsNullOrEmpty($Script:PasswordTextBox.Text)
  ) {
    $Script:SendButton.Enabled = $False
  }
  Else {
    $Script:SendButton.Enabled = $True
  }
}

# Initialize the active state of the Send button.
Set-SendButtonEnabled
# Set that any change in one of the header text fields changes the active state of the Send button.
$ComputerNameTextBox.add_TextChanged({
  Set-SendButtonEnabled
})
$UsernameTextBox.add_TextChanged({
  Set-SendButtonEnabled
})
$PasswordTextBox.add_TextChanged({
  Set-SendButtonEnabled
})

Export-ModuleMember -Variable *

# Just for making the code clean.
[void] $MessageTextBox