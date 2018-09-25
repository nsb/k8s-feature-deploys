pipeline {
    agent none
    options {
        timestamps()
        disableConcurrentBuilds()
    }
    environment {
        REGISTRY_CRED = credentials('container_registry')
    }

    stages {
        stage('Test') {
            agent { label 'docker' }
            steps {
                sh 'make ci-push'
            }
        }

        stage('Create and migrate database feature') {
            agent { label 'docker' }
            when {
                branch 'feature-*'
                beforeAgent true
            }
            steps {
                sh 'make db-create-and-migrate'
            }
        }

        stage('Deploy feature') {
            when {
                branch "feature-*"
                beforeAgent true
            }
            agent { label 'docker' }
                sh 'make k8s_deploy'
            }
            post {
              always {
                sh 'make ci-export-url'
                script {
                  env.URL_HOSTNAME = readFile '_url_hostname.txt'
                }
              }
              success {
                slackSend channel: '#k8s-feature-deploys', color: 'good', message: "${env.JOB_NAME} feature deployed to ${env.URL_HOSTNAME}."
              }
              failure {
                slackSend channel: '#k8s-feature-deploys', color: 'warning', message: "${env.JOB_NAME} feature: failure"
              }
            }
        }

        stage('Prod migrate database') {
            agent { label 'dockeredge' }
            when {
                branch 'master'
                beforeAgent true
            }
            steps {
                sh 'make db-create-and-migrate'
            }
        }

        stage('Deploy prod') {
            when {
                branch "master"
                beforeAgent true
            }
            agent { label 'docker' }
            steps {
                sh 'make k8s_deploy'
            }
            post {
              always {
                sh 'make ci-export-url'
                script {
                  env.URL_HOSTNAME = readFile '_url_hostname.txt'
                }
              }
              success {
                slackSend channel: '#k8s-feature-deploys', color: 'good', message: "${env.JOB_NAME} prod deployed to ${env.URL_HOSTNAME}."
              }
              failure {
                slackSend channel: '#k8s-feature-deploys', color: 'warning', message: "${env.JOB_NAME} prod: failure"
              }
            }
        }
    }
}
