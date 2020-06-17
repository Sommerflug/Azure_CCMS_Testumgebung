<#
    (1) Ändern des LW-Letter für das CD-Rom-LW auf A
    (2) Initialisierung der zusätzlichen Festplatte als E:\
    (3) Runterladen der Exchange-Iso auf C:
    (4) Extrahieren der ISO auf C:
#>


Start-Transcript C:\transscript.txt

# (1) Set CD/DVD Drive to A:
Get-WmiObject -Class Win32_volume -Filter 'DriveType=5' |
Select-Object -First 1 |
Set-WmiInstance -Arguments @{DriveLetter='A:'}



# (2) Leere HD ermitteln -> initialisieren
Get-Disk | Where-Object NumberOfPartitions -eq 0 | Select-Object -first 1 | 
Initialize-Disk -PartitionStyle MBR -PassThru | 
New-Partition -UseMaximumSize -DriveLetter E | 
Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false -Force



# (3) Download ISO
$uri = "https://ccmsspeicher.blob.core.windows.net/addons/ExchangeServer2016-x64-CU15.ISO"
$destination = "C:\ExchangeISO"
if(!(Test-path $destination)){
    New-Item -Path $destination -ItemType Directory
}

$destinationFile = $null
$result = $false
$retries = 3

# Stop retrying after download succeeds or all retries attempted
while(($retries -gt 0) -and ($result -eq $false)) {
    try	{
        "Downloading ISO from URI: $uri to destination: $destination"
        $isoFileName = [System.IO.Path]::GetFileName($uri)
        $webClient = New-Object System.Net.WebClient
        $destinationFile = "$destination\$isoFileName"
        $webClient.DownloadFile($uri, $destinationFile)
        
        if((Test-Path $destinationFile) -eq $true) {
            "Downloading ISO file succeeded"
            $result = $true
        }
        else {
            "Downloading ISO file failed"
            $result = $false
        }
    } catch [Exception] {
        "Failed to download ISO. Exception: $_"
        $retries--
        if($retries -eq 0) {
            Remove-Item $destination -Force -Confirm:0 -ErrorAction SilentlyContinue
        }
    }
}



# (4) Extract ISO
if($result){
    "Mount the image from $destinationFile"
    $image = Mount-DiskImage -ImagePath $destinationFile -PassThru
    $driveLetter = ($image | Get-Volume).DriveLetter

    "Copy files to destination directory: $destination"
    Robocopy.exe ("{0}:" -f $driveLetter) $destination /E | Out-Null

    "Dismount the image from $destinationFile"
    Dismount-DiskImage -ImagePath $destinationFile

    "Delete the temp file: $destinationFile"
    Remove-Item -Path $destinationFile -Force
}else{
    "Failed to download the file after exhaust retry limit"
    Remove-Item $destination -Force -Confirm:0 -ErrorAction SilentlyContinue
    Throw "Failed to download the file after exhaust retry limit"
}


Stop-Transcript


