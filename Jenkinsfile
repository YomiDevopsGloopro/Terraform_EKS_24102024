pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    try {
                        // Improved checkout with explicit use of credentials
                        checkout([$class: 'GitSCM', 
                                  branches: [[name: '*/main']],
                                  userRemoteConfigs: [[
                                      url: 'https://github.com/glooproo/terraform.git',
                                      credentialsId: 'github-username-password-auth'
                                  ]]
                        ])
                        echo "Code checkout successful."
                    } catch (Exception e) {
                        echo "Code checkout failed: ${e.message}"
                        error("Exiting due to code checkout failure.")
                    }
                }
            }
        }
        stage('Initializing Terraform') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform init'
                    }
                }
                echo "Terraform initialized."
            }
        }
        stage('Validating Terraform') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform validate'
                    }
                }
                echo "Terraform configuration validated."
            }
        }
        stage('Previewing the infrastructure') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform plan'
                    }
                    input(message: "Approve?", ok: "proceed")
                }
                echo "Infrastructure previewed; awaiting approval."
            }
        }
        stage('Create/Destroy an EKS cluster') {
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform $action --auto-approve'
                    }
                }
                echo "Terraform action executed: $action."
            }
        }
    }
    post {
        always {
            script {
                BUILD_COLOR = "danger"
                if (currentBuild.currentResult == "SUCCESS") {
                    BUILD_COLOR = "good"
                }
            }
            slackSend channel: 'a_build_notifications',
                      color: "${BUILD_COLOR}",
                      message: "Find Status of Pipeline: ${currentBuild.currentResult} - ${env.JOB_NAME} #${env.BUILD_NUMBER} ${env.BUILD_URL}"
            echo "Slack notification sent with build status."
        }
    }
}
