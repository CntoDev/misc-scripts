# for older PS versions
function Is64Bit { [System.IntPtr]::Size -eq 8 }

# to download/replace
$be_baseurl = 'http://www.battleye.com/downloads/arma3/'
$be_bins = @('BEClient.dll', 'BEService.exe',
	     'BEService_x64.exe', 'BEServer.dll')


$ErrorActionPreference = "Stop"

# arma3 install dir
Write-Host "getting arma3 install dir"
# TODO: 32bit windows?
$key = 'HKLM:\SOFTWARE\Wow6432Node\bohemia interactive\arma 3'
$a3path = (Get-ItemProperty -Path "$key" -Name main).main
$a3be = "$a3path\BattlEye"

# delete be binaries in a3 dir
# - no need, DownloadFile overwrites them
#foreach ($bin in $be_bins) {
#	$bin = "$a3be\$bin"
#	if (Test-Path "$bin") {
#		Remove-Item "$bin" -whatif
#	}
#}

# download new
foreach ($bin in $be_bins) {
	Write-Host "downloading $bin"
	$src = "$be_baseurl/$bin"
	$dst = "$a3be\$bin"
	# no Invoke-WebRequest in PS2
	(new-object System.Net.WebClient).DownloadFile("$src", "$dst")
}

# copy BeClient.dll to AppData\Local
$be_local = "$env:LOCALAPPDATA\Arma 3\BattlEye"
if (Test-Path "$be_local") {
	Write-Host "copying to Local\Arma 3\BE"
	Copy-Item -Force "$a3be\BeClient.dll" "$be_local\BeClient.dll"
}

# copy BEService.exe to CommonFiles
$cfdir = "$env:CommonProgramFiles"
if (Is64Bit) { $cfdir = "${env:CommonProgramFiles(x86)}" }
$be_cf = "$cfdir\BattlEye"
if (Test-Path "$be_cf") {
	Write-Host "copying to CommonFiles\BE"
	if (Is64Bit) {
		Copy-Item -Force "$a3be\BEService_x64.exe" "$be_cf\BEService.exe"
	} else {
		Copy-Item -Force "$a3be\BEService.exe" "$be_cf\BEService.exe"
	}
	# ?? because arma needs it ??
	Copy-Item -Force "$be_cf\BEService.exe" "$be_cf\BEService_arma3.exe"
}

Write-Host "all done"
