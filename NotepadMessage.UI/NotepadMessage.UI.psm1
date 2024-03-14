using namespace System.Windows.Forms
using namespace System.Drawing

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$SenderDialog = [Form]::New() | ForEach-Object {
  $_.Size = '300, 550'
  $_.Text = 'Notepad Message'
  $_.Icon = [Icon]::New("$PSScriptRoot\ui.ico")
  $_.Font = 'Verdana,10'
  $_.StartPosition = 'CenterScreen'
  $_.MinimumSize = $_.Size
  $_.MaximumSize = $_.Size
  Return $_
}
$SenderDialog.Controls.AddRange(@(
  ($ComputerNameTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 260
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 35"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Computer name:'
    $_.Location = '10, 15'
    Return $_
  }
  ($UsernameTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 260
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 90"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Username:'
    $_.Location = '10, 70'
    Return $_
  }
  ($PasswordTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 260
    $_.BorderStyle = 'FixedSingle'
    $_.Location = "12, 145"
    $_.Text = '';
    $_.PasswordChar = '*';
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Password:'
    $_.Location = '10, 125'
    Return $_
  }
  ($MessageTextBox = [TextBox]::new() | ForEach-Object {
    $_.Width = 260
    $_.Height = 200
    $_.BorderStyle = 'FixedSingle'
    $_.Multiline = $True
    $_.Location = "12, 240"
    Return $_
  })
  [Label]::new() | ForEach-Object {
    $_.AutoSize = $True
    $_.Text = 'Message:'
    $_.Location = '10, 220'
    Return $_
  }
  ($SendButton = [Button]::new() | ForEach-Object {
    $_.Width = 260
    $_.Text = 'Send'
    $_.AutoSize = $True
    $_.FlatStyle = 'Flat'
    $_.Location = '12, 455'
    Return $_
  })
))

Function Set-SendButtonEnabled {
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

Set-SendButtonEnabled
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

[void] $MessageTextBox