pipeline {
    agent any

    environment {
        DOCKER_COMPOSE_CMD = 'docker-compose -f infrastructure/docker-compose.yml'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git submodule update --init --recursive'
            }
        }

        stage('Lint & Static Analysis') {
            parallel {
                stage('Backend (Python)') {
                    steps {
                        dir('backend') {
                            sh 'uv sync'
                            sh 'uv run ruff check .'
                            sh 'uv run mypy app/'
                        }
                    }
                }
                stage('Frontend (Angular)') {
                    steps {
                        dir('frontend') {
                            sh 'npm ci'
                            sh 'npm run lint'
                        }
                    }
                }
            }
        }

        stage('Unit Tests & Coverage') {
            parallel {
                stage('Backend') {
                    steps {
                        dir('backend') {
                            sh 'uv run pytest --cov=app --cov-report=xml tests/'
                        }
                        junit 'backend/test-results.xml'
                    }
                }
                stage('Frontend') {
                    steps {
                        dir('frontend') {
                            sh 'npm run test -- --watch=false --code-coverage'
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                dir('infrastructure') {
                    sh "${DOCKER_COMPOSE_CMD} build"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline Passed Successfully!"
        }
        failure {
            echo "Pipeline Failed. Check logs."
        }
    }
}
