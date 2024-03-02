pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }  

      stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }

      stage('Mutation Tests - PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post {
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
      }

      stage('SonarQube - SAST') {
        steps {
          sh "mvn clean verify sonar:sonar \
                -Dsonar.projectKey=numeric-application \
                -Dsonar.projectName='numeric-application' \
                -Dsonar.host.url=http://devsecops-tamer.eastus.cloudapp.azure.com:9000 \
                -Dsonar.token=sqp_0198b1b7cdf3c65a5b031882be1880cffe9299cd"
        }
      }

      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t tamerben/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push tamerben/numeric-app:""$GIT_COMMIT""'
              }
            }
      }

      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#tamerben/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
              }
            }
      }
    }
}