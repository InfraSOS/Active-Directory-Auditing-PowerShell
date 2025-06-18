
###############################################################################################################################################################################
#
# PowerShell auditing for Windows Event viewer Event IDs. 
#
# Add the Event ID you would like to search for.
#
# Try InfraSOS.com an Active Directory Reporting & Auditing solution with built-in scheduling and security assessments for deeper analysis.
#
################################################################################################################################################################################

 # Update the past number of days to search for and the Event ID you would like to search for. 
$lastWeek = (Get-Date).AddDays(-1)  # Past 1 Days. To increase days simply replace the 1 with the number of past days to check.
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4720; StartTime=$lastWeek}|  
Export-Csv "C:\AuditReports\Audit-Report.csv" -NoTypeInformation  #Add the location to export a CSV, if you would like to export the report to a specific location.

############################################################################################################################################
## To Audit multiple Event IDs, you can use the following script.
######
$eventIDs = @(4625, 4740) # Event IDs: 4625 = Failed Logon, 4740 = Account Lockout. Add the EventIDs you would like to report on, separated by comma ','.
$exportPath = "C:\AuditReports\AuditEvents.csv" # Add the path to store CSV output locally
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