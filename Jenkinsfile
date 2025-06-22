pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare sample_log.log') {
            steps {
                sh '''
cat > sample_log.log <<EOF
INFO Start
ERROR Something failed
CRITICAL Disk error
INFO End
EOF
'''
                sh 'ls -l sample_log.log'
                sh 'cat sample_log.log'
            }
        }

        stage('Check for sample_log.log') {
            steps {
                script {
                    if (fileExists('sample_log.log')) {
                        echo "sample_log.log exists in workspace."
                        sh 'ls -l sample_log.log'
                        sh 'cat sample_log.log'
                    } else {
                        error("sample_log.log does NOT exist in workspace!")
                    }
                }
            }
        }

        stage('Build') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    echo 'Building with Maven...'
                    sh 'mvn clean package'
                }
            }
        }

        stage('Test') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    echo 'Running JUnit tests...'
                    sh 'mvn test'
                }
            }
        }

        stage('Ansible Setup') {
            steps {
                echo 'Running Ansible playbook...'
                sh 'ansible-playbook -i ansible/inventory ansible/setup.yml -K || true'
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
        }
    }
}
