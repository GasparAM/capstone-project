pipeline {
    agent {label 'FargateAgent'}

    triggers {
        pollSCM '*/5 * * * *'
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

        stage('Docker up main') {
            when {
                branch 'main' 
            }
            steps {
                sh '''
                    service docker start
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
                    service docker start
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
                        echo $TOKEN | docker login -u gavetisyangd --password-stdin
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
                        echo $TOKEN | docker login -u gavetisyangd --password-stdin
                        docker push "113304117666.dkr.ecr.eu-north-1.amazonaws.com/mr:${GIT_COMMIT}"
                    '''
                }
            }
        }
    }
}
