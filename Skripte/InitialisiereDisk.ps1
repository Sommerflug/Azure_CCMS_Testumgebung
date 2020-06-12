Start-Transcript C:\transscript.txt

# Set CD/DVD Drive to A:
Get-WmiObject -Class Win32_volume -Filter 'DriveType=5' |
Select-Object -First 1 |
Set-WmiInstance -Arguments @{DriveLetter='A:'}

#Leere HD ermitteln -> initialisieren
$disk = Get-Disk | Where-Object NumberOfPartitions -eq 0 | Select-Object -first 1

$disk | 
Initialize-Disk -PartitionStyle MBR -PassThru | 
New-Partition -UseMaximumSize -DriveLetter E | 
Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false -Force

Stop-Transcript


