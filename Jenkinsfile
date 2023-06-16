pipeline {
   agent any

   environment {
    // the address of your harbor registry
     REGISTRY = 'https://harbor.datamarket.local:9443'
     REGISTRY_PATH = 'harbor.datamarket.local:9443/app/spring-app'
     HARBOR = 'harbor'
  }
    stages {
        stage('Github') {
            steps {
                git (
                    url: 'https://github.com/serkancakar/Spring-App.git',
                    branch: 'main'
                    )
            }
        }

        stage('Maven Build') {
            steps {
                script {
                    sh './mvnw clean package'
                    }
                }
             }
        stage('Docker Image to Harbor'){
          steps {
            script {
              docker.withRegistry("$REGISTRY", "$HARBOR") {
                def app = docker.build("harbor.datamarket.local:9443/app/spring-app:${env.BUILD_NUMBER}")
                app.push()
              //  sh 'docker image rm harbor.datamarket.local:9443/app/spring-app:${env.BUILD_ID}'
             }
          }
        }
      }


        stage('Trigger ManifestUpdate') {
          steps {
                   echo "triggering updatemanifestjob"
                   build job: 'updatemanifest' /* parameters: [string(name: 'DOCKERTAG', value: '${env.BUILD_ID}')] */
                }
               }
    }
   }

