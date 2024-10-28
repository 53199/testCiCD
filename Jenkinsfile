pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Clonage du code source depuis le dépôt...'
                checkout scm
            }
        }
        stage('Execute PowerShell Script') {
            steps {
                echo 'Exécution du script PowerShell...'
                dir("${env.WORKSPACE}") {
                    powershell '''
                        # Définir l'encodage de la console pour corriger les problèmes d'affichage
                        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

                        # Définir le répertoire de travail
                        $currentDir = $env:WORKSPACE
                        if (-not $currentDir) {
                            $currentDir = 'C:\\Users\\TDPTIJ\\Desktop\\test'
                        }

                        Write-Host "Valeur de Get-Location : $(Get-Location)"
                        Write-Host "Valeur de $currentDir : $currentDir"

                        # Liste des modules à regrouper
                        $modules = @('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'PackageManagement')

                        # Chemin du répertoire de destination pour les modules regroupés
                        $destinationPath = Join-Path -Path $currentDir -ChildPath "ModulesRegroupes"

                        # Chemin du fichier ZIP pour la compression des modules
                        $zipPath = Join-Path -Path $currentDir -ChildPath "ModulesRegroupes.zip"

                        # Vérifier si le répertoire de destination existe, sinon le créer
                        if (!(Test-Path -Path $destinationPath)) {
                            New-Item -ItemType Directory -Path $destinationPath -Force
                            Write-Host "Répertoire créé : $destinationPath"
                        } else {
                            Write-Host "Le répertoire $destinationPath existe déjà."
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

                        # Supprimer le fichier ZIP existant s'il existe
                        if (Test-Path -Path $zipPath) {
                            Remove-Item -Path $zipPath -Force
                            Write-Host "Fichier ZIP existant supprimé : $zipPath"
                        }

                        # Compresser le répertoire de modules
                        Compress-Archive -Path "$destinationPath\\*" -DestinationPath $zipPath -Force

                        Write-Host "Modules regroupés et compressés dans '$zipPath'."
                    '''
                }
            }
        }
        stage('Archive Artifacts') {
            steps {
                echo 'Archivage des modules regroupés...'
                archiveArtifacts artifacts: 'ModulesRegroupes.zip', fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Le pipeline s\'est terminé avec succès.'
        }
        failure {
            echo 'Le pipeline a échoué.'
        }
    }
}
