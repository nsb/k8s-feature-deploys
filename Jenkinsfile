pipeline {
    agent none
    options {
        timestamps()
        disableConcurrentBuilds()
    }
    environment {
        REGISTRY_CRED = credentials('revenueoptimisation_acr')
    }

    stages {
        stage('Test') {
            agent { label 'dockeredge' }
            steps {
                sh 'make ci-push'
            }
        }

        stage('Create and migrate database feature') {
            agent { label 'dockeredge' }
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
            agent { label 'dockeredge' }
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
            agent { label 'dockeredge' }
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
