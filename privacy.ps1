#Requires -RunAsAdministrator

param (
    [switch]$StopDynamicServices, # Parametr do zatrzymania dynamicznych usług
    [switch]$StartDynamicServices # Parametr do uruchomienia dynamicznych usług
)

# List of critical services (will not be modified)
$criticalServices = @(
    "Winlogon",           # Windows Logon Process - Handles user login processes
    "ProfSvc",            # User Profile Service - Manages user profiles
    "gpsvc",              # Group Policy Client - Manages group policies
    "VaultSvc",           # Credential Manager - Stores and manages user credentials
    "EventLog",           # Windows Event Log - Logs system and application events
    "CoreMessagingRegistrar", # Core Messaging - Handles inter-process communication
    "seclogon",           # Secondary Logon - Allows processes to run with different credentials
    "WdiSystemHost",      # Diagnostic System Host - Handles system diagnostics
    "UI0Detect",          # Interactive Services Detection - Detects interactive services
    "TokenBroker"         # Handles authentication processes in UWP applications
)

# Define categorized services
# Data collection and telemetry services - Not required for normal operation and may impact privacy
$dataCollectionServices = @(
    "diagnosticshub.standardcollector.service", # Diagnostics Hub Standard Collector Service
    "DiagTrack",                                # Connected User Experiences and Telemetry
    "dmwappushservice",                         # Device Management Wireless Application Protocol (WAP) Push service
    "WpcMonSvc",                                # Family Safety Monitor Service
    "AppIDSvc",                                 # Application Identity Service
    "dptftcs"                                   # Data Pipeline Transfer Service
)

# Network services that are not needed for home users and may pose a security risk
$networkServices = @(
    "RemoteRegistry",   # Allows remote access to the registry
    "lmhosts",          # Supports NetBIOS name resolution
    "iphlpsvc",         # IP Helper Service - Provides tunnel connectivity
    "SNMPTrap",         # SNMP Trap - Receives trap messages generated by local or remote SNMP agents
    "Browser",          # Computer Browser Service - Maintains an updated list of computers on the network
    "ALG"               # Application Layer Gateway - Provides support for network protocols
)

# Bluetooth services that can be disabled if Bluetooth is not used
$bluetoothServices = @(
    "BthAvctpSvc",                # Bluetooth Audio/Video Control Transport Protocol Service
    "BluetoothUserService_48486de" # Bluetooth Support Service for specific users
)

# Other services that can be safely disabled to improve system performance
$otherServices = @(
    "MapsBroker",               # Downloads map data for offline use
    "TrkWks",                   # Distributed Link Tracking Client - Keeps track of linked files
    "WMPNetworkSvc",            # Windows Media Player Network Sharing Service
    "WerSvc",                   # Windows Error Reporting Service
    "Fax",                      # Fax Service
    "fhsvc",                    # File History Service
    "gupdate",                  # Google Update Service
    "gupdatem",                 # Google Update Service (Machine-Level)
    "stisvc",                   # Windows Image Acquisition (WIA) Service
    "AJRouter",                 # AllJoyn Router Service
    "MSDTC",                    # Microsoft Distributed Transaction Coordinator
    "PhoneSvc",                 # Phone Service
    "PcaSvc",                   # Program Compatibility Assistant Service
    "WPDBusEnum",               # Portable Device Enumerator Service
    "LicenseManager",           # License Management Service
    "wisvc",                    # Windows Insider Service
    "RetailDemo",               # Retail Demo Service
    "SCardSvr",                 # Smart Card Service
    "SCPolicySvc",              # Smart Card Removal Policy
    "ScDeviceEnum",             # Smart Card Device Enumeration Service
    "EntAppSvc",                # Enterprise App Management Service
    "BDESVC",                   # BitLocker Drive Encryption Service
    "edgeupdate",               # Microsoft Edge Update Service
    "MicrosoftEdgeElevationService", # Microsoft Edge Elevation Service
    "edgeupdatem",              # Microsoft Edge Update Service (Machine-Level)
    "SEMgrSvc",                 # Payments and NFC/SE Manager Service
    "PerfHost",                 # Performance Counter DLL Host
    "DusmSvc",                  # Data Usage Service
    "RtkBtManServ",             # Realtek Bluetooth Management Service
    "QWAVE",                    # Quality Windows Audio Video Experience
    "cbdhsvc_48486de",          # Clipboard User Service
    "tapisrv",                  # Telephony Service
    "RmSvc",                    # Radio Management Service
    "SensorDataService",        # Sensor Data Service
    "camsvc",                   # Capability Access Manager Service
    "CDPSvc",                   # Connected Devices Platform Service
    "CDPUserSvc_7b51c",         # Connected Devices Platform User Service
    "CertPropSvc",              # Certificate Propagation
    "hidserv",                  # Human Interface Device Service
    "ipfsvc",                   # IKE and AuthIP IPsec Keying Modules
    "jhi_service",              # Intel(R) Dynamic Application Loader Host Interface Service
    "webthreatdefusersvc_7b51c",# Web Threat Defense User Service
    "WpnUserService_7b51c"      # Windows Push Notification User Service
)

# Dynamic services to control with Start-DynamicServices and Stop-DynamicServices
$dynamicServices = @(
    "wlidsvc",        # Windows Live ID Sign-in Assistant
    "StateRepository", # GUI elements and UWP apps
    "FontCache",      # Windows Font Cache Service
    "DoSvc",          # Delivery Optimization
    "wuauserv"        # Windows Update
)

# Map dynamic services to their default start types
$dynamicServicesStartType = @{
    "wlidsvc" = 3          # Manual
    "StateRepository" = 2  # Automatic
    "FontCache" = 2        # Automatic
    "DoSvc" = 2            # Automatic
    "wuauserv" = 3         # Manual
}

# Combine all categorized services into a single list for disabling
$servicesToDisable = $dataCollectionServices + $networkServices + $bluetoothServices + $otherServices
# Remove critical and dynamic services from the disable list
$servicesToDisable = $servicesToDisable | Where-Object { $_ -notin $criticalServices } | Where-Object { $_ -notin $dynamicServices }

# Initialize progress bar
$totalServices = $servicesToDisable.Count
$progressCounter = 0

# Prepare log file
$logFile = ".\log.txt"
if (Test-Path $logFile) {
    Remove-Item $logFile
}

# Disable unnecessary services
foreach ($service in $servicesToDisable) {
    $progressCounter++
    $progressPercentage = [math]::Round(($progressCounter / $totalServices) * 100)
    Write-Progress -Activity "Disabling Services" -Status "Processing $service ($progressCounter of $totalServices)" -PercentComplete $progressPercentage
    try {
        if ($service -eq "TrkWks") {
            # Use sc.exe for TrkWks due to permission issues
            $cmd = "sc.exe config TrkWks start= disabled"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru
        } else {
            $registryPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$service"
            $cmd = "reg add `"$registryPath`" /v Start /t REG_DWORD /d 4 /f"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru
        }
        if ($result.ExitCode -eq 0) {
            Write-Host "[$progressPercentage%] Disabled service: $service" -ForegroundColor Green
            Write-Output "[$(Get-Date)] Disabled service: $service" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host "[$progressPercentage%] Failed to disable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
            Write-Output "[$(Get-Date)] Failed to disable service: $service. Exit Code: $($result.ExitCode)" | Out-File -FilePath $logFile -Append
        }
    } catch {
        Write-Host "[$progressPercentage%] Error occurred while disabling service: $service" -ForegroundColor Red
        Write-Output "[$(Get-Date)] Error occurred while disabling service: $service. Error: $_" | Out-File -FilePath $logFile -Append
    }
}

Write-Host "Service optimization completed successfully!" -ForegroundColor Cyan
Write-Output "[$(Get-Date)] Service optimization completed." | Out-File -FilePath $logFile -Append

# Function to stop dynamic services
function Stop-DynamicServices {
    # Prepare log file
    $logFile = ".\log.txt"
    foreach ($service in $dynamicServices) {
        try {
            $registryPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$service"
            $cmd = "reg add `"$registryPath`" /v Start /t REG_DWORD /d 4 /f"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru
            if ($result.ExitCode -eq 0) {
                Write-Host "Disabled service: $service" -ForegroundColor Green
                Write-Output "[$(Get-Date)] Disabled service: $service" | Out-File -FilePath $logFile -Append
            } else {
                Write-Host "Failed to disable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
                Write-Output "[$(Get-Date)] Failed to disable service: $service. Exit Code: $($result.ExitCode)" | Out-File -FilePath $logFile -Append
            }
        } catch {
            Write-Host "Error occurred while disabling service: $service" -ForegroundColor Red
            Write-Output "[$(Get-Date)] Error occurred while disabling service: $service. Error: $_" | Out-File -FilePath $logFile -Append
        }
    }
    Write-Host "Dynamic services have been disabled." -ForegroundColor Cyan
}

# Function to start dynamic services
function Start-DynamicServices {
    # Prepare log file
    $logFile = ".\log.txt"
    foreach ($service in $dynamicServices) {
        try {
            $startType = $dynamicServicesStartType[$service]
            $registryPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$service"
            $cmd = "reg add `"$registryPath`" /v Start /t REG_DWORD /d $startType /f"
            $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru
            if ($result.ExitCode -eq 0) {
                Write-Host "Enabled service: $service (Start Type: $startType)" -ForegroundColor Green
                Write-Output "[$(Get-Date)] Enabled service: $service (Start Type: $startType)" | Out-File -FilePath $logFile -Append
            } else {
                Write-Host "Failed to enable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
                Write-Output "[$(Get-Date)] Failed to enable service: $service. Exit Code: $($result.ExitCode)" | Out-File -FilePath $logFile -Append
            }
        } catch {
            Write-Host "Error occurred while enabling service: $service" -ForegroundColor Red
            Write-Output "[$(Get-Date)] Error occurred while enabling service: $service. Error: $_" | Out-File -FilePath $logFile -Append
        }
    }
    Write-Host "Dynamic services have been enabled." -ForegroundColor Cyan
}

# Check parameters and execute accordingly
if ($StopDynamicServices) {
    Stop-DynamicServices
} elseif ($StartDynamicServices) {
    Start-DynamicServices
} else {
    Write-Host "No dynamic action specified. Skipping dynamic services operation." -ForegroundColor Yellow
}

# Example usage:
# To disable dynamic services: powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StopDynamicServices
# To enable dynamic services: powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StartDynamicServices
