pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }

    tools {
        maven 'mvn_3.9.16'
    }

    stages {
        stage('Code Compilation') {
            steps {
                echo 'Starting Code Compilation...'
                sh 'mvn clean compile'
                echo 'Code Compilation Completed Successfully!'
            }
        }

        stage('Code QA Execution') {
            steps {
                echo 'Running JUnit Test Cases...'
                sh 'mvn test'
                echo 'JUnit Test Cases Completed Successfully!'
            }
        }

        stage('Code Package') {
            steps {
                echo 'Creating Artifact...'
                sh 'mvn package'
                sh '''
                    # If WAR is expected
                    cp target/*.jar target/adha-${BUILD_NUMBER}.jar
                '''
                archiveArtifacts artifacts: 'target/adha-*.jar', fingerprint: true
                echo 'Artifact Created Successfully!!'
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                sh "docker build -t sagarchattar/adha:latest -t adha:latest ."
            }
        }

        stage('Docker Image Scanning') {
            steps {
                echo 'Scanning Docker Image with Trivy...'
                sh 'trivy image sagarchattar/adha:latest || echo "Scan Failed - Proceeding with Caution"'
                echo 'Docker Image Scanning Completed!'
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhubCred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh "docker tag adha:latest $DOCKER_USER/adha:latest"
                        sh "docker push $DOCKER_USER/adha:latest"
                    }
                }
            }
        }

        stage('Push Docker Image to Amazon ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'ecr-credentials']]) {
                        sh '''
                            aws ecr get-login-password --region ap-south-1 | \
                              docker login --username AWS --password-stdin 251335054837.dkr.ecr.ap-south-1.amazonaws.com

                            docker tag adha:latest 251335054837.dkr.ecr.ap-south-1.amazonaws.com/sagardocker:adha-latest
                            docker push 251335054837.dkr.ecr.ap-south-1.amazonaws.com/sagardocker:adha-latest
                        '''
                        echo 'Docker Image Pushed to Amazon ECR Successfully!'
                    }
                }
            }
        }
        stage('Upload Docker Image to Harbor') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh '''
                    echo "$PASSWORD" | docker login 43.205.199.72:8082 -u "$USERNAME" --password-stdin
                    docker tag adha:latest 43.205.199.72:8082/adha/adha:latest
                    docker push 43.205.199.72:8082/adha/adha:latest
                    docker logout 43.205.199.72:8082
                    '''
                    }
                }
            }
        }
        stage('Clean Up Local Docker Images') {
            steps {
                echo 'Cleaning Up Local Docker Images...'
                sh '''
                docker rmi sagarchattar/adha:latest || echo "Image not found or already deleted"
                docker rmi adha:latest || echo "Image not found or already deleted"
                docker rmi 251335054837.dkr.ecr.ap-south-1.amazonaws.com/sagarchattar:adha-latest || echo "Image not found or already deleted"
                docker rmi 43.205.199.72:8082/adha/adha:latest || echo "Image not found or already deleted"
                docker image prune -f
                '''
                echo 'Local Docker Images Cleaned Up Successfully!!'
            }
        }
    }
}