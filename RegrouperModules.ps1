# Liste des modules à regrouper
# On va mettre dans un tableau les différents modules qui nous intéressent
$modules = @('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'PackageManagement')

# Choisir le chemin où tous ces modules iront
$destinationPath = "C:\ModulesRegroupes"

# Vérifier si le répertoire existe sinon on le recrée
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force
}

foreach ($module in $modules) {
    $moduleInfo = Get-Module -ListAvailable -Name $module | Select-Object -First 1

    if ($moduleInfo) {
        $modulePath = $moduleInfo.ModuleBase
        Copy-Item -Path $modulePath -Destination $destinationPath -Recurse -Force
        Write-Host "Le module '$module' a été copié dans $destinationPath"
    } else {
        Write-Host "Le module '$module' n'existe pas. Tentative d'installation..."
        try {
            Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "Module '$module' installé avec succès."
            # Récupérer les informations du module après l'installation
            $moduleInfo = Get-Module -ListAvailable -Name $module | Select-Object -First 1
            if ($moduleInfo) {
                $modulePath = $moduleInfo.ModuleBase
                Copy-Item -Path $modulePath -Destination $destinationPath -Recurse -Force
                Write-Host "Le module '$module' a été copié dans $destinationPath"
            } else {
                Write-Host "Le module '$module' n'a pas pu être trouvé après l'installation." -ForegroundColor Red
            }
        } catch {
            Write-Host "Impossible d'installer le module '$module'." -ForegroundColor Red
        }
    }
}

# Chemin du fichier ZIP
$zipPath = "C:\ModulesRegroupes.zip"

# Supprimer le fichier ZIP existant s'il existe
if (Test-Path -Path $zipPath) {
    Remove-Item -Path $zipPath -Force
}

# Compresser le répertoire de modules
Compress-Archive -Path "$destinationPath\*" -DestinationPath $zipPath -Force

Write-Host "Modules regroupés et compressés dans '$zipPath'."

<#
.SYNOPSIS
    Script pour regrouper les modules nécessaires.

.DESCRIPTION
    Ce script copie les modules spécifiés vers un répertoire et les compresse pour le partage.

.EXAMPLE
    .\RegrouperModules.ps1
#>
