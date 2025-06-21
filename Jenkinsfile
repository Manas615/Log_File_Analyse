pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Clone the repository (if using a Jenkins job with SCM)
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building with Maven...'
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                echo 'Running JUnit tests...'
                sh 'mvn test'
            }
        }

        stage('Ansible Setup') {
            steps {
                echo 'Running Ansible playbook...'
                sh 'ansible-playbook -i ansible/inventory ansible/setup.yml -K || true'
                // The '|| true' allows the pipeline to continue if Ansible prompts for a password or fails due to sudo
            }
        }

        stage('Log Analysis') {
            steps {
                echo 'Running log analyzer script...'
                sh './log_analyzer.sh sample_log.log'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t log-analyzer:latest .'
            }
        }

        stage('Docker Run') {
            steps {
                echo 'Running Docker container...'
                sh 'docker run --rm -v $(pwd)/sample_log.log:/app/sample_log.log log-analyzer:latest ./log_analyzer.sh sample_log.log'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            // Add archiving or cleanup steps here if needed
        }
    }
}
