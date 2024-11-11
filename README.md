# WindowsServiceOptimizer

## How to run:

1. Open PowerShell as Administrator.
2. Run the following command:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1
   ```
   ```powershell
   Stop-DynamicServices
   ```

## Restore if needed:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy_restore.ps1
   ```
   ```powershell
   Start-DynamicServices
   ```
