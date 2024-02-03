# Ensure running in PowerShell with Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an Administrator." -ForegroundColor Red
    exit
}

# Function to safely change user passwords with confirmation and enhanced error handling
function Change-UserPassword {
    param (
        [string]$userName
    )
    try {
        $newPassword = Read-Host "Enter new password for $userName (input will be hidden)" -AsSecureString
        $confirmPassword = Read-Host "Confirm new password for $userName (input will be hidden)" -AsSecureString

        # Convert SecureStrings to plaintext for comparison
        $ptr1 = [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($newPassword)
        $ptr2 = [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($confirmPassword)
        try {
            $password1 = [Runtime.InteropServices.Marshal]::PtrToStringUni($ptr1)
            $password2 = [Runtime.InteropServices.Marshal]::PtrToStringUni($ptr2)

            if ($password1 -eq $password2) {
                Set-LocalUser -Name $userName -Password $newPassword
                Write-Host "Password successfully changed for $userName." -ForegroundColor Green
            } else {
                Write-Host "Passwords do not match. No changes made for $userName." -ForegroundColor Yellow
            }
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr1)
            [Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr2)
        }
    } catch {
        Write-Host "An error occurred changing password for ${userName}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# List and manage local users
$localUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.PrincipalSource -eq "Local" } | Select-Object -ExpandProperty Name
Write-Host "Local users:" -ForegroundColor Cyan
$localUsers | ForEach-Object { Write-Host $_ }

# Pause to review the user list
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

foreach ($user in $localUsers) {
    $changePassword = Read-Host "Do you want to change the password for $user? (y/n)"
    if ($changePassword -eq 'y') {
        Change-UserPassword -userName $user
    }
    # Pause after each password change operation
    Write-Host "Press any key to continue to the next user..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Clear Command History with confirmation
$clearHistory = Read-Host "Do you want to clear the command history for this session? (y/n)"
if ($clearHistory -eq 'y') {
    Clear-History
    Write-Host "Command history cleared." -ForegroundColor Green
} else {
    Write-Host "Skipped clearing command history." -ForegroundColor Yellow
}

# Final pause before script completion
Write-Host "Script execution completed. Press any key to exit." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
