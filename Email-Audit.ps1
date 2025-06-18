###############################################################################################################################################################################
#
# PowerShell auditing for Windows Event viewer Event IDs. Update your SMTP information below and set this script as a scheduled task if you would like to schedule email reports.
#
# Filter by the number of past days to check. By default its set to past 24 hours, update your desired time below.
#
# Try InfraSOS.com an Active Directory Reporting & Auditing solution with built-in scheduling and security assessments for deeper analysis.
#
################################################################################################################################################################################

# Configurable Variables
$eventIDs = @(4625, 4740) # Event IDs: 4625 = Failed Logon, 4740 = Account Lockout. Add the EventIDs you would like to report on, separated by comma ','.
$date = Get-Date -Format "MM-dd-yyyy-HH:mm"
$exportPath = "C:\AuditReports\AuditEvents.csv" # Add the path to store CSV output locally
$smtpServer = "smtp.yourdomain.com" # Update with your SMTP Server
$smtpPort = 587 # Update with your SMTP Server port
$smtpUser = "alerts@yourdomain.com" # Add your SMTP Mailbox Username
$smtpPass = "Password" # Add your SMTP Mailbox User Password
$SecurePassword = ConvertTo-SecureString $smtpPass -AsPlainText -Force
$from = "alerts@yourdomain.com" # Your from address
$to = "itsecurity@yourcompany.com" # Which address to deliver the report
$subject = "Windows Security Audit Report"
$body = "Attached is the latest Active Directory security audit report on the selected Windows Events $eventIDs "
$SMTPCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, $SecurePassword  


# Query Windows Security Log
Write-Host "Collecting Windows Events..."
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = $eventIDs
    StartTime = (Get-Date).AddDays(-1)   # Last 24 hours. To increase days simply replace the 1 with the number of past days to check.
} -ErrorAction SilentlyContinue

# Export to CSV

    New-Item -ItemType Directory -Path (Split-Path $exportPath) -Force

$events |
    Select-Object TimeCreated, Id, Message |
    Export-Csv -Path $exportPath -NoTypeInformation -Force

Write-Host "Events exported to $exportPath"

# Prepare email attachment
$attachment = New-Object System.Net.Mail.Attachment($exportPath)

# Send email
Write-Host "Sending email with audit report..."

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $exportPath -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $SMTPCredential

Write-Host "Email sent to $to with audit report attached."




