@Library('aline-shared-lib') _

pipeline {
  agent any

  parameters {
    string(name: "action", defaultValue: "apply", description: "Action to be taken by Terraform as final step.")
  }

  environment {
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    AWS_REGION = "us-east-2"
    TFVARS = credentials('aline_tfvars_file')
    cluster_name = "aline_EKS_cluster"
    KUBE_CONFIG_PATH="~/.kube/config"
  }

  stages {
    stage('Init') {
      steps {
        script {
          dir("Terraform/main_stack") {
            terraform.init()
          }
        }
      }
    }

    stage('Plan') {
      steps {
        script {
          dir("Terraform/main_stack") {
            terraform.plan()
          }
        }
      }
    }

    stage('Lint') {
      when {
        expression {
          params.action != "destroy"
        }
      }

      steps {
        script {
          dir("Terraform/main_stack") {
            sh "tflint --init"
            sh "tflint --module --recursive"
          }
        }
      }
    }
    
    stage('Test') {
      when {
        expression {
          params.action != "destroy"
        }

        anyOf {
          branch 'master';
          branch 'develop';
        }
      }

      steps {
        script {
          dir("Terraform/main_stack/test") {
            sh "go mod init modules"
            sh "go mod tidy"
            sh "go test -v -timeout 0"
          }
        }
      }
    }

    stage('Action') {
      when {
        anyOf {
          branch 'master';
          branch 'develop';
        }
      }

      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
          script {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "aws-credentials", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
              dir("Terraform/main_stack") {
                terraform.action("${params.action}")
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}