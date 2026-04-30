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
//   db-admin-username       Secret Text      PostgreSQL administrator username
//   db-admin-password       Secret Text      PostgreSQL administrator password
//   app-secret-key          Secret Text      Backend JWT signing key
//   Provider/vector credentials from infrastructure/docs/provider-runtime-contract.md
//
// Jenkins plugins required:
//   GitHub, Docker, Credentials Binding, Azure CLI, Input Step, Git
// =============================================================================

def providerCredentialSpecs(selectedProviders) {
    def specsByProvider = [
        'openai':    [[credentialsId: 'openai-api-key',    variable: 'OPENAI_API_KEY',    terraformVariable: 'TF_VAR_openai_api_key']],
        'anthropic': [[credentialsId: 'anthropic-api-key', variable: 'ANTHROPIC_API_KEY', terraformVariable: 'TF_VAR_anthropic_api_key']],
        'groq':      [[credentialsId: 'groq-api-key',      variable: 'GROQ_API_KEY',      terraformVariable: 'TF_VAR_groq_api_key']],
        'together':  [[credentialsId: 'together-api-key',  variable: 'TOGETHER_API_KEY',  terraformVariable: 'TF_VAR_together_api_key']],
        'google':    [[credentialsId: 'google-api-key',    variable: 'GOOGLE_API_KEY',    terraformVariable: 'TF_VAR_google_api_key']]
    ]

    selectedProviders.collectMany { provider -> specsByProvider.get(provider, []) }
}

def vectorCredentialSpecs(vectorStore) {
    def specsByStore = [
        'qdrant': [
            [credentialsId: 'qdrant-url',        variable: 'QDRANT_URL',        terraformVariable: 'TF_VAR_qdrant_url'],
            [credentialsId: 'qdrant-api-key-ro', variable: 'QDRANT_API_KEY_RO', terraformVariable: 'TF_VAR_qdrant_api_key_ro'],
            [credentialsId: 'qdrant-api-key-rw', variable: 'QDRANT_API_KEY_RW', terraformVariable: 'TF_VAR_qdrant_api_key_rw']
        ],
        'pinecone': [[credentialsId: 'pinecone-api-key', variable: 'PINECONE_API_KEY', terraformVariable: 'TF_VAR_pinecone_api_key']],
        'pgvector': [[credentialsId: 'pgvector-dsn',     variable: 'PGVECTOR_DSN',     terraformVariable: 'TF_VAR_pgvector_dsn']]
    ]

    specsByStore.get(vectorStore, [])
}

def provisioningCredentialSpecs(params) {
    def selectedProviders = [
        params.CLASSIFIER_PROVIDER,
        params.REASONING_PROVIDER,
        params.EMBEDDING_PROVIDER
    ].toSet()

    def specs = [
        [credentialsId: 'db-admin-username', variable: 'DB_ADMIN_USERNAME', terraformVariable: 'TF_VAR_db_admin_username'],
        [credentialsId: 'db-admin-password', variable: 'DB_ADMIN_PASSWORD', terraformVariable: 'TF_VAR_db_admin_password'],
        [credentialsId: 'app-secret-key',    variable: 'APP_SECRET_KEY',    terraformVariable: 'TF_VAR_app_secret_key']
    ]

    specs.addAll(providerCredentialSpecs(selectedProviders))
    specs.addAll(vectorCredentialSpecs(params.VECTOR_STORE))

    specs.unique { spec -> spec.credentialsId }
}

def provisioningCredentialBindings(params) {
    provisioningCredentialSpecs(params).collect { spec ->
        string(credentialsId: spec.credentialsId, variable: spec.variable)
    }
}

def provisioningTerraformSecretExports(params) {
    provisioningCredentialSpecs(params).collect { spec ->
        "export ${spec.terraformVariable}=\\\"\\$${spec.variable}\\\""
    }.join('\n                        ')
}

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
        choice(name: 'CLASSIFIER_PROVIDER', choices: ['anthropic', 'openai', 'groq', 'together', 'ollama', 'google'], description: 'Classifier provider.')
        string(name: 'CLASSIFIER_MODEL', defaultValue: 'claude-haiku-4-5-20251001', description: 'Classifier model.')
        choice(name: 'REASONING_PROVIDER', choices: ['anthropic', 'openai', 'groq', 'together', 'ollama', 'google'], description: 'Reasoning provider.')
        string(name: 'REASONING_MODEL', defaultValue: 'claude-sonnet-4-6', description: 'Reasoning and Q&A model.')
        choice(name: 'EMBEDDING_PROVIDER', choices: ['openai', 'ollama', 'sentence-transformers', 'huggingface', 'google'], description: 'Embedding provider.')
        string(name: 'EMBEDDING_MODEL', defaultValue: 'text-embedding-3-large', description: 'Embedding model shared with RAG ingestion.')
        string(name: 'EMBEDDING_DIMENSION', defaultValue: '3072', description: 'Embedding dimension shared with RAG ingestion.')
        choice(name: 'VECTOR_STORE', choices: ['qdrant', 'chromadb', 'pinecone', 'pgvector'], description: 'Vector store provider.')
        string(name: 'VECTOR_COLLECTION_PREFIX', defaultValue: 'movies', description: 'Vector collection/table/namespace prefix.')
        string(name: 'OLLAMA_BASE_URL', defaultValue: 'http://localhost:11434', description: 'Ollama base URL when selected.')
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
        stage('Provision Staging') {
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
                script {
                    withCredentials(provisioningCredentialBindings(params)) {
                        sh """
                        export ARM_CLIENT_ID="\$AZURE_SP_USR"
                        export ARM_CLIENT_SECRET="\$AZURE_SP_PSW"
                        export ARM_SUBSCRIPTION_ID="\$AZURE_SUBSCRIPTION_ID"
                        export ARM_TENANT_ID="\$AZURE_TENANT_ID"
                        export TF_VAR_azure_subscription_id="\$AZURE_SUBSCRIPTION_ID"
                        export TF_VAR_environment=staging
                        export TF_VAR_backend_image_tag="${env.BUILD_TAG}"
                        export TF_VAR_frontend_image_tag="${env.BUILD_TAG}"
                        export TF_VAR_acr_admin_enabled=true
                        ${provisioningTerraformSecretExports(params)}
                        export TF_VAR_classifier_provider="${params.CLASSIFIER_PROVIDER}"
                        export TF_VAR_classifier_model="${params.CLASSIFIER_MODEL}"
                        export TF_VAR_reasoning_provider="${params.REASONING_PROVIDER}"
                        export TF_VAR_reasoning_model="${params.REASONING_MODEL}"
                        export TF_VAR_embedding_provider="${params.EMBEDDING_PROVIDER}"
                        export TF_VAR_embedding_model="${params.EMBEDDING_MODEL}"
                        export TF_VAR_embedding_dimension="${params.EMBEDDING_DIMENSION}"
                        export TF_VAR_vector_store="${params.VECTOR_STORE}"
                        export TF_VAR_vector_collection_prefix="${params.VECTOR_COLLECTION_PREFIX}"
                        export TF_VAR_ollama_base_url="${params.OLLAMA_BASE_URL}"
                        cd infrastructure
                        make init
                        make apply
                        """
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
        stage('Provision Production') {
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
                script {
                    withCredentials(provisioningCredentialBindings(params)) {
                        sh """
                        export ARM_CLIENT_ID="\$AZURE_SP_USR"
                        export ARM_CLIENT_SECRET="\$AZURE_SP_PSW"
                        export ARM_SUBSCRIPTION_ID="\$AZURE_SUBSCRIPTION_ID"
                        export ARM_TENANT_ID="\$AZURE_TENANT_ID"
                        export TF_VAR_azure_subscription_id="\$AZURE_SUBSCRIPTION_ID"
                        export TF_VAR_environment=production
                        export TF_VAR_backend_image_tag="${env.BUILD_TAG}"
                        export TF_VAR_frontend_image_tag="${env.BUILD_TAG}"
                        export TF_VAR_acr_admin_enabled=true
                        ${provisioningTerraformSecretExports(params)}
                        export TF_VAR_classifier_provider="${params.CLASSIFIER_PROVIDER}"
                        export TF_VAR_classifier_model="${params.CLASSIFIER_MODEL}"
                        export TF_VAR_reasoning_provider="${params.REASONING_PROVIDER}"
                        export TF_VAR_reasoning_model="${params.REASONING_MODEL}"
                        export TF_VAR_embedding_provider="${params.EMBEDDING_PROVIDER}"
                        export TF_VAR_embedding_model="${params.EMBEDDING_MODEL}"
                        export TF_VAR_embedding_dimension="${params.EMBEDDING_DIMENSION}"
                        export TF_VAR_vector_store="${params.VECTOR_STORE}"
                        export TF_VAR_vector_collection_prefix="${params.VECTOR_COLLECTION_PREFIX}"
                        export TF_VAR_ollama_base_url="${params.OLLAMA_BASE_URL}"
                        cd infrastructure
                        make init
                        make apply
                        """
                    }
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
