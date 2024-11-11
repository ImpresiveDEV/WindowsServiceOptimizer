# WindowsServiceOptimizer

## How to run:

1. Open PowerShell as Administrator.
2. Run the following command:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StopDynamicServices
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StartDynamicServices
   ```

## Restore if needed:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy_restore.ps1
   ```
