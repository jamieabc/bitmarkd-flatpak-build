def repo = 'bitmarkd-flatpak-build'
def git_url = "https://github.com/jamieabc/${repo}.git"
def directory = 'flatpak'
def bitmarkd_flatpak_file = 'com.bitmark.bitmarkd.json'
def recorderd_flatpak_file = 'com.bitmark.recorderd.json'
def success_code = '0'
def tag = '0'

node (label: "aws-builder") {
    stage('Checkout') {
        echo 'Checkout'
        tag = input(
            message: 'Please provide bitmarkd tag to build',
            parameters: [
                [
                    $class: 'StringParameterDefinition',
                    default: 'None',
                    description: 'tag',
                    name: 'tag'],
            ],
        )
        dir(directory) {
            sh 'rm -rf *'
            git url: "https://github.com/jamieabc/${repo}.git", branch: "master"
            sh "chmod u+x build.sh"
            sh "chmod u+x generate-flatpak.sh"
            sh "chmod u+x upload.sh"
        }
    }

    stage('Generate flatpak build file') {
        echo 'Generate flatpak build file'
        dir(directory) {
            sh "./generate-flatpak.sh ${tag}"
        }
    }

    stage('Build flatpak bundle') {
        echo 'Build flatpak bundle'
        dir(directory) {
            // build.sh has a dependency: output file is (second argument).flatpak
            // e.g. bitmarkd => bitmarkd.flatpak
            sh "./build.sh ${bitmarkd_flatpak_file} bitmarkd"
            sh "./build.sh ${recorderd_flatpak_file} recorderd"
        }
    }

    stage('Upload to S3') {
        echo 'Upload to S3'
        dir(directory){
            sh "./upload.sh ${tag}"
        }
    }
}
