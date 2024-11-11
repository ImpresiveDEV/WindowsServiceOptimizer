# Windows Service Optimizer & Debloater

## How to run:

1. Open PowerShell as Administrator.
2. Run **ONLY THE ONE** the following command:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StopDynamicServices  #BREAK MICROSOFT AUTHENTICATION/UPDATES ETC 
   powershell -ExecutionPolicy Bypass -File .\privacy.ps1 -StartDynamicServices #LITE VERSION
   ```

## Restore if needed:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\privacy_restore.ps1
   ```
