Start-Transcript C:\transscript.txt

$disk = Get-Disk | Where-Object NumberOfPartitions -eq 0 | Select-Object -first 1

$disk | 
Initialize-Disk -PartitionStyle MBR -PassThru | 
New-Partition -UseMaximumSize -DriveLetter E | 
Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false -Force

Stop-Transcript


