pipeline {
    agent any

    stages {
        stage('Git') {
            steps {
                git url: 'https://github.com/JNSalvatierra/challenge-infra.git', branch: "${params.BRANCH}"
            }
        }
        stage('Build Docker Images'){
            steps {
                sh '''
                    docker build ./vote -f $WORKSPACE/vote/Dockerfile -t jnsalvatierra/challenge-infra:vote-$BUILD_NUMBER
                    docker build ./result -f $WORKSPACE/result/Dockerfile -t jnsalvatierra/challenge-infra:result-$BUILD_NUMBER
                    docker build ./worker -f $WORKSPACE/worker/Dockerfile -t jnsalvatierra/challenge-infra:worker-$BUILD_NUMBER
                '''
            }            
        }
        stage('Push Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
                sh '''
                    docker push jnsalvatierra/challenge-infra:vote-$BUILD_NUMBER
                    docker push jnsalvatierra/challenge-infra:result-$BUILD_NUMBER
                    docker push jnsalvatierra/challenge-infra:worker-$BUILD_NUMBER
                '''
            }
        }
        stage('Deploy') {
            steps {
                script {
                    input message: '¿Aprobar el despliegue?', ok: 'Deploy', submitter: 'admin'
                }

                withCredentials([usernamePassword(credentialsId: 'argocd_pass', usernameVariable: 'ARGO_USER', passwordVariable: 'ARGO_PASS')]) {
                    sh '''
                        kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &
                        sleep 10
                        argocd login localhost:8085 --username $ARGO_USER --password $ARGO_PASS --insecure

                        argocd --grpc-web app set vote --kustomize-image jnsalvatierra/challenge-infra:vote-$BUILD_NUMBER
                        argocd --grpc-web app set result --kustomize-image jnsalvatierra/challenge-infra:result-$BUILD_NUMBER
                        argocd --grpc-web app set worker --kustomize-image jnsalvatierra/challenge-infra:worker-$BUILD_NUMBER
                    '''
                }    
            }
        }
    }
}
