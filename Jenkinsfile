pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: podman
    image: quay.io/podman/stable
    securityContext:
      privileged: true
    command: ['cat']
    tty: true
  - name: trivy
    image: aquasec/trivy:0.69.3
    command: ['cat']
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
'''
        }
    }

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "dulyakit-lab/graphql-subscription"
        TAG = "${env.BUILD_NUMBER}" // ใช้เลข Build เป็น Tag
        NAMESPACE = "development"
        CRED_ID = "ghcr-login" // ID ของ Credentials ที่เราสร้างไว้ใน Jenkins
    }

    stages {
        stage('📥 Checkout') {
            steps {
                checkout scm
            }
        }

        stage('🐳 Build Image') {
            steps {
                container('podman') {
                    sh "podman build -t ${REGISTRY}/${IMAGE_NAME}:${TAG} ."
                    // Save image เป็นไฟล์เพื่อส่งต่อให้ Trivy สแกน (ไม่ต้อง push ก่อน)
                    sh "podman save -o image.tar ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                }
            }
        }

        stage('🛡️ Security Scan (Trivy)') {
            steps {
                container('trivy') {
                    // สแกนไฟล์ image.tar ที่ build มา
                    // --exit-code 1 หมายถึง ถ้าเจอความเสี่ยงระดับ HIGH/CRITICAL ให้สั่ง Pipeline พังทันที (หยุดการ push)
                    sh "trivy image --input image.tar --severity HIGH,CRITICAL --exit-code 1"
                }
            }
        }

        stage('🚀 Push to GHCR') {
            steps {
                container('podman') {
                    withCredentials([usernamePassword(credentialsId: env.CRED_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo \$PASS | podman login ${REGISTRY} -u \$USER --password-stdin"
                        sh "podman push ${REGISTRY}/${IMAGE_NAME}:${TAG}"
                    }
                }
            }
        }

        stage('☸️ Deploy to K3s') {
            steps {
                container('kubectl') {
                    // สั่ง Update Image ใน Deployment (Namespace development)
                    sh "kubectl set image deployment/graphql-subscription graphql-subscription=${REGISTRY}/${IMAGE_NAME}:${TAG} -n ${NAMESPACE}"
                    sh "kubectl rollout status deployment/graphql-subscription -n ${NAMESPACE}"
                }
            }
        }
    }
    
    post {
        always {
            cleanWs() // ลบ Workspace หลังทำงานเสร็จเพื่อประหยัดที่ใน Fedora
        }
    }
}