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
                powershell script: '.\\RegrouperModules.ps1', pwsh: false, executionPolicy: 'Bypass'
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
