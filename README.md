# WindowsServiceOptimizer

## How to run:

1. Open PowerShell as Administrator.
2. Run the following command:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StopDynamicServices
   ```

## Restore if needed:

   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\Users\IMPRESIVE\privacy_restore.ps1" -StartDynamicServices
   ```
