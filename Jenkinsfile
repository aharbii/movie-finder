// =============================================================================
// movie-finder — Root orchestration Jenkins pipeline
//
// This pipeline builds app images and manages deployments.
// Submodule CI pipelines (backend, frontend) run their own lint/test jobs and
// report back. This pipeline handles everything downstream:
//
//   Build      — build and push backend + frontend images to ACR
//   Deploy     — rolling update of Azure Container Apps (staging then prod)
//
// Pipeline modes:
//   Push to main  — Build both images + Auto-deploy to staging
//   v* tag        — Build both images + Auto-deploy staging + Manual prod gate
//   Manual        — workflow_dispatch with optional deploy flags
//
// Triggers:
//   • Push to main (via GitHub webhook or polling)
//   • Any v* tag
//   • Manual "Build with Parameters"
// Jenkins credentials required (Manage Jenkins → Credentials → Global):
//   acr-login-server        Secret Text      Full ACR hostname, e.g. myacr.azurecr.io
//   acr-credentials         Username+Pass    SP App ID (user) + client secret (pass)
//   azure-subscription-id   Secret Text      Azure subscription ID
//   azure-tenant-id         Secret Text      Azure tenant ID
//   azure-sp-credentials    Username+Pass    SP App ID (user) + client secret (pass) for AZ CLI
//
// Jenkins plugins required:
//   GitHub, Docker, Credentials Binding, Azure CLI, Input Step, Git
// =============================================================================

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds(abortPrevious: true)
        skipDefaultCheckout()
    }

    parameters {
        booleanParam(
            name: 'DEPLOY_STAGING',
            defaultValue: true,
            description: 'Deploy to staging after a successful build.'
        )
        booleanParam(
            name: 'DEPLOY_PRODUCTION',
            defaultValue: false,
            description: 'Request manual production deployment gate after staging.'
        )
        choice(
            name: 'WITH_PROVIDERS',
            choices: ['default-cloud', 'ollama-qdrant', 'cloud', 'local', 'all-providers'],
            description: 'Backend chain provider SDK bundle installed at Docker build time.'
        )
    }

    environment {
        BACKEND_IMAGE  = 'movie-finder-backend'
        FRONTEND_IMAGE = 'movie-finder-frontend'
        // Isolate compose project per build.
        COMPOSE_PROJECT_NAME = "movie-finder-ci-${env.BUILD_NUMBER}"
    }

    stages {

        // ------------------------------------------------------------------ //
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: scm.branches,
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[
                        $class: 'SubmoduleOption',
                        disableSubmodules: false,
                        parentCredentials: true,
                        recursiveSubmodules: true,
                        trackingSubmodules: false
                    ]],
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
            }
        }

        // ------------------------------------------------------------------ //
        stage('Resolve Tag') {
            steps {
                script {
                    // Use git tag if on a release tag, otherwise use short SHA.
                    env.BUILD_TAG = env.GIT_TAG_NAME ?: env.GIT_COMMIT.take(8)
                    echo "Build tag: ${env.BUILD_TAG}"
                }
            }
        }

        // ------------------------------------------------------------------ //
        stage('Build Images') {
            environment {
                ACR_SERVER      = credentials('acr-login-server')
                ACR_CREDENTIALS = credentials('acr-credentials')
            }
            steps {
                sh 'echo "$ACR_CREDENTIALS_PSW" | docker login "$ACR_SERVER" -u "$ACR_CREDENTIALS_USR" --password-stdin'
                parallel(
                    'Backend': {
                        script {
                            def fullImage = "${env.ACR_SERVER}/${env.BACKEND_IMAGE}:${env.BUILD_TAG}"
                            sh "docker pull ${env.ACR_SERVER}/${env.BACKEND_IMAGE}:latest || true"
                            sh """
                                docker build \
                                    --cache-from ${env.ACR_SERVER}/${env.BACKEND_IMAGE}:latest \
                                    --build-arg WITH_PROVIDERS=${params.WITH_PROVIDERS} \
                                    -t ${fullImage} \
                                    backend/
                            """
                            sh "docker push ${fullImage}"
                            if (env.BRANCH_NAME == 'main') {
                                sh "docker tag ${fullImage} ${env.ACR_SERVER}/${env.BACKEND_IMAGE}:latest"
                                sh "docker push ${env.ACR_SERVER}/${env.BACKEND_IMAGE}:latest"
                            }
                            env.BACKEND_FULL_IMAGE = fullImage
                        }
                    },
                    'Frontend': {
                        script {
                            def fullImage = "${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:${env.BUILD_TAG}"
                            sh "docker pull ${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:latest || true"
                            sh """
                                docker build \
                                    --cache-from ${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:latest \
                                    -t ${fullImage} \
                                    frontend/
                            """
                            sh "docker push ${fullImage}"
                            if (env.BRANCH_NAME == 'main') {
                                sh "docker tag ${fullImage} ${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:latest"
                                sh "docker push ${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:latest"
                            }
                            env.FRONTEND_FULL_IMAGE = fullImage
                        }
                    }
                )
            }
            post {
                always {
                    sh 'docker logout "$ACR_SERVER" || true'
                    sh "docker rmi ${env.BACKEND_FULL_IMAGE} || true"
                    sh "docker rmi ${env.FRONTEND_FULL_IMAGE} || true"
                    script {
                        if (env.BRANCH_NAME == 'main') {
                            sh "docker rmi ${env.ACR_SERVER}/${env.BACKEND_IMAGE}:latest || true"
                            sh "docker rmi ${env.ACR_SERVER}/${env.FRONTEND_IMAGE}:latest || true"
                        }
                    }
                }
            }
        }

        // ------------------------------------------------------------------ //
        stage('Deploy to Staging') {
            when {
                expression {
                    return params.DEPLOY_STAGING && (env.BRANCH_NAME == 'main' || env.GIT_TAG_NAME)
                }
            }
            environment {
                AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
                AZURE_TENANT_ID       = credentials('azure-tenant-id')
                AZURE_SP             = credentials('azure-sp-credentials')
            }
            steps {
                sh '''
                    az login \
                        --service-principal \
                        --username  "$AZURE_SP_USR" \
                        --password  "$AZURE_SP_PSW" \
                        --tenant    "$AZURE_TENANT_ID"
                    az account set --subscription "$AZURE_SUBSCRIPTION_ID"
                '''
                sh """
                    az containerapp update \
                        --name    movie-finder-backend-staging \
                        --resource-group movie-finder-staging \
                        --image   ${env.BACKEND_FULL_IMAGE}
                    az containerapp update \
                        --name    movie-finder-frontend-staging \
                        --resource-group movie-finder-staging \
                        --image   ${env.FRONTEND_FULL_IMAGE}
                """
            }
            post {
                always {
                    sh 'az logout || true'
                }
            }
        }

        // ------------------------------------------------------------------ //
        stage('Production Gate') {
            when {
                expression {
                    return params.DEPLOY_PRODUCTION && (env.BRANCH_NAME == 'main' || env.GIT_TAG_NAME)
                }
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input(
                        message: "Deploy ${env.BUILD_TAG} to production?",
                        ok: 'Deploy to Production',
                        submitter: 'admin'
                    )
                }
            }
        }

        // ------------------------------------------------------------------ //
        stage('Deploy to Production') {
            when {
                expression {
                    return params.DEPLOY_PRODUCTION && (env.BRANCH_NAME == 'main' || env.GIT_TAG_NAME)
                }
            }
            environment {
                AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
                AZURE_TENANT_ID       = credentials('azure-tenant-id')
                AZURE_SP             = credentials('azure-sp-credentials')
            }
            steps {
                sh '''
                    az login \
                        --service-principal \
                        --username  "$AZURE_SP_USR" \
                        --password  "$AZURE_SP_PSW" \
                        --tenant    "$AZURE_TENANT_ID"
                    az account set --subscription "$AZURE_SUBSCRIPTION_ID"
                '''
                sh """
                    az containerapp update \
                        --name    movie-finder-backend \
                        --resource-group movie-finder-prod \
                        --image   ${env.BACKEND_FULL_IMAGE}
                    az containerapp update \
                        --name    movie-finder-frontend \
                        --resource-group movie-finder-prod \
                        --image   ${env.FRONTEND_FULL_IMAGE}
                """
            }
            post {
                always {
                    sh 'az logout || true'
                }
            }
        }

    }

    post {
        always {
            cleanWs()
        }
        failure {
            echo "Root pipeline failed on ${env.BRANCH_NAME ?: env.GIT_TAG_NAME ?: 'unknown ref'}."
        }
        success {
            script {
                if (env.GIT_TAG_NAME && params.DEPLOY_PRODUCTION) {
                    echo "Release ${env.GIT_TAG_NAME} deployed to production."
                } else if (env.BRANCH_NAME == 'main' && params.DEPLOY_STAGING) {
                    echo "Build ${env.BUILD_TAG} deployed to staging."
                } else {
                    echo "Images built and pushed for ${env.BRANCH_NAME ?: env.GIT_TAG_NAME}."
                }
            }
        }
    }
}
