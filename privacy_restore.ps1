#Requires -RunAsAdministrator

# Lista usług do włączenia
$servicesToEnable = @(
    "diagnosticshub.standardcollector.service",
    "DiagTrack",
    "dmwappushservice",
    "WpcMonSvc",
    "AppIDSvc",
    "dptftcs",
    "RemoteRegistry",
    "lmhosts",
    "iphlpsvc",
    "SNMPTrap",
    "Browser",
    "ALG",
    "BthAvctpSvc",
    "BluetoothUserService_48486de",
    "MapsBroker",
    "TrkWks", # Specjalne traktowanie dla tej usługi
    "WMPNetworkSvc",
    "WerSvc",
    "Fax",
    "fhsvc",
    "gupdate",
    "gupdatem",
    "stisvc",
    "AJRouter",
    "MSDTC",
    "PhoneSvc",
    "PcaSvc",
    "WPDBusEnum",
    "LicenseManager",
    "wisvc",
    "RetailDemo",
    "SCardSvr",
    "SCPolicySvc",
    "ScDeviceEnum",
    "EntAppSvc",
    "BDESVC",
    "edgeupdate",
    "MicrosoftEdgeElevationService",
    "edgeupdatem",
    "SEMgrSvc",
    "PerfHost",
    "DoSvc",
    "DusmSvc",
    "RtkBtManServ",
    "QWAVE",
    "cbdhsvc_48486de",
    "tapisrv",
    "RmSvc",
    "SensorDataService",
    "camsvc",
    "CDPSvc",
    "CDPUserSvc_7b51c",
    "CertPropSvc",
    "hidserv",
    "ipfsvc",
    "jhi_service",
    "webthreatdefusersvc_7b51c",
    "WpnUserService_7b51c",
    "wuauserv",
    "StateRepository",    # GUI elements and UWP apps
    "FontCache"           # Windows Font Cache Service
)

# Zainicjalizuj pasek postępu
$totalServices = $servicesToEnable.Count
$progressCounter = 0

# Przygotuj plik logu
$logFile = ".\enable_services_log.txt"
if (Test-Path $logFile) {
    Remove-Item $logFile
}

# Włączanie usług
foreach ($service in $servicesToEnable) {
    $progressCounter++
    $progressPercentage = [math]::Round(($progressCounter / $totalServices) * 100)
    Write-Progress -Activity "Enabling Services" -Status "Processing $service ($progressCounter of $totalServices)" -PercentComplete $progressPercentage

    try {
        if ($service -eq "TrkWks") {
            # Specjalne traktowanie dla usługi TrkWks
            $cmd = "sc.exe config TrkWks start= demand"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru

            if ($result.ExitCode -eq 0) {
                Write-Host "[$progressPercentage%] Enabled service: $service (Handled with sc.exe)" -ForegroundColor Green
                Write-Output "[$(Get-Date)] Enabled service: $service (Handled with sc.exe)" | Out-File -FilePath $logFile -Append
            } else {
                Write-Host "[$progressPercentage%] Failed to enable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
                Write-Output "[$(Get-Date)] Failed to enable service: $service (Exit Code: $($result.ExitCode))" | Out-File -FilePath $logFile -Append
            }
        } else {
            $registryPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$service"
            $cmd = "reg add `"$registryPath`" /v Start /t REG_DWORD /d 3 /f"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru

            if ($result.ExitCode -eq 0) {
                Write-Host "[$progressPercentage%] Enabled service: $service" -ForegroundColor Green
                Write-Output "[$(Get-Date)] Enabled service: $service" | Out-File -FilePath $logFile -Append
            } else {
                Write-Host "[$progressPercentage%] Failed to enable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
                Write-Output "[$(Get-Date)] Failed to enable service: $service (Exit Code: $($result.ExitCode))" | Out-File -FilePath $logFile -Append
            }
        }
    } catch {
        Write-Host "[$progressPercentage%] Error occurred while enabling service: $service" -ForegroundColor Red
        Write-Output "[$(Get-Date)] Error occurred while enabling service: $service. Error: $_" | Out-File -FilePath $logFile -Append
    }
}

Write-Host "Service restoration completed successfully!" -ForegroundColor Cyan
Write-Output "[$(Get-Date)] Service restoration completed." | Out-File -FilePath $logFile -Append
