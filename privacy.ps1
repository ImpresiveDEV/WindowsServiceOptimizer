#Requires -RunAsAdministrator

# List of critical services (will not be modified)
$criticalServices = @(
    "Winlogon",           # Windows Logon Process - Handles user login processes
    "ProfSvc",            # User Profile Service - Manages user profiles
    "gpsvc",              # Group Policy Client - Manages group policies
    "VaultSvc",           # Credential Manager - Stores and manages user credentials
    "EventLog",           # Windows Event Log - Logs system and application events
    "CoreMessagingRegistrar", # Core Messaging - Handles inter-process communication
    "seclogon",           # Secondary Logon - Allows processes to run with different credentials
    "StateRepository",    # State Repository Service - Manages UWP applications and GUI elements
    "WdiSystemHost",      # Diagnostic System Host - Handles system diagnostics
    "UI0Detect",          # Interactive Services Detection - Detects interactive services
    "TokenBroker",        # Handles authentication processes in UWP applications
    "wlidsvc"             # Windows Live ID Sign-in Assistant - Manages Microsoft account login
)

# List of dynamic services (excluding TokenBroker since it's critical)
$dynamicServices = @(
    "wlidsvc",        # Windows Live ID Sign-in Assistant
    "StateRepository", # GUI elements and UWP apps
    "FontCache",      # Windows Font Cache Service
    "DoSvc",          # Delivery Optimization
    "wuauserv"        # Windows Update
)

# List of other services to disable
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
    "FontCache",                # Windows Font Cache Service
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
    "DoSvc",                    # Delivery Optimization
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
    "WpnUserService_7b51c",     # Windows Push Notification User Service
    "wuauserv"                  # Windows Update Service
)

# Combine all services to disable
$servicesToDisable = $otherServices

# Remove critical services from the list of services to disable
$servicesToDisable = $servicesToDisable | Where-Object { $_ -notin $criticalServices }

# Disable unnecessary services at system startup
$totalServices = $servicesToDisable.Count
$progressCounter = 0
foreach ($service in $servicesToDisable) {
    $progressCounter++
    $progressPercentage = [math]::Round(($progressCounter / $totalServices) * 100)
    Write-Progress -Activity "Disabling Services" -Status "Processing $service ($progressCounter of $totalServices)" -PercentComplete $progressPercentage

    try {
        $cmd = "sc.exe config $service start= disabled"
        $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru

        if ($result.ExitCode -eq 0) {
            Write-Host "[$progressPercentage%] Disabled service: $service" -ForegroundColor Green
        } else {
            Write-Host "[$progressPercentage%] Failed to disable service: $service (Exit Code: $($result.ExitCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[$progressPercentage%] Error occurred while disabling service: $service" -ForegroundColor Red
    }
}

# Set dynamic services to manual start mode
foreach ($service in $dynamicServices) {
    try {
        $cmd = "sc.exe config $service start= demand"
        $result = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -NoNewWindow -Wait -PassThru

        if ($result.ExitCode -eq 0) {
            Write-Host "Service $service has been set to manual start mode." -ForegroundColor Green
        } else {
            Write-Host "Failed to set manual start mode for service: $service" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error occurred while processing service: $service. Error: $_" -ForegroundColor Red
    }
}

# Function to start dynamic services on demand
function Start-DynamicServices {
    Write-Host "Starting dynamic services..." -ForegroundColor Cyan
    foreach ($service in $dynamicServices) {
        try {
            Start-Service -Name $service -ErrorAction Stop
            Write-Host "Service $service has been started." -ForegroundColor Green
        } catch {
            Write-Host "Failed to start service: $service. Error: $_" -ForegroundColor Red
        }
    }
}

# Function to stop dynamic services
function Stop-DynamicServices {
    Write-Host "Stopping dynamic services..." -ForegroundColor Cyan
    foreach ($service in $dynamicServices) {
        try {
            Stop-Service -Name $service -Force -ErrorAction Stop
            Write-Host "Service $service has been stopped." -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to stop service: $service. Error: $_" -ForegroundColor Red
        }
    }
}

# Instructions for the user
Write-Host "To start dynamic services when needed, use the command: Start-DynamicServices" -ForegroundColor Yellow
Write-Host "To stop dynamic services, use the command: Stop-DynamicServices" -ForegroundColor Yellow
Write-Host "Script execution completed." -ForegroundColor Cyan
