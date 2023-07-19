pipeline {
    agent {label 'ec2'}

    triggers {
        githubPush()
    }

    stages {
        stage('ENV') {
            steps {
                sh '''
                    printenv
                    echo $CHANGE_BRANCH
                '''
            }
        }
        stage('Checkstyle') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                sh '''
                    ./mvnw checkstyle:checkstyle
                '''
            }
        }

        stage('Test') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                sh '''
                    ./mvnw test
                '''
            }
        }

        stage('Build') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                sh '''
                    ./mvnw clean package -Dmaven.test.skip=true
                '''
            }
        }

        stage('Set up ECR environment') {
            steps {
                sh '''
                    apk add --no-cache aws-cli
                '''
            }
        }

        stage('Docker up main') {
            when {
                branch 'main' 
            }
            steps {
                sh '''
                    docker build -t "113304117666.dkr.ecr.eu-north-1.amazonaws.com/main:${GIT_COMMIT}" ./ 
                '''
            }
        }

        stage('Docker up mr') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                sh '''
                    docker build -t "113304117666.dkr.ecr.eu-north-1.amazonaws.com/mr:${GIT_COMMIT}" ./ 
                '''
            }
        }

        stage('Push main') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'dhub', variable: 'TOKEN')]) {
                    sh '''
                        aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin "113304117666.dkr.ecr.eu-north-1.amazonaws.com"
                        docker push "113304117666.dkr.ecr.eu-north-1.amazonaws.com/main:${GIT_COMMIT}"
                    '''
                }
            }
        }

        stage('Push mr') {
            when {
                not {
                    branch 'main'
                }
            }
            steps {
                withCredentials([string(credentialsId: 'dhub', variable: 'TOKEN')]) {
                    sh '''
                        aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin "113304117666.dkr.ecr.eu-north-1.amazonaws.com"
                        docker push "113304117666.dkr.ecr.eu-north-1.amazonaws.com/mr:${GIT_COMMIT}"
                    '''
                }
            }
        }
    }
}
