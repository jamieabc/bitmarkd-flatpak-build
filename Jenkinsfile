def repo = 'bitmarkd-flatpak-build'
def directory = 'flatpak'
def bitmarkd_flatpak_file = 'com.bitmark.bitmarkd.json'
def recorderd_flatpak_file = 'com.bitmark.recorderd.json'

node (label: "aws-builder") {
    stage('Checkout') {
        echo 'Checkout'
        dir(directory) {
            sh 'rm -rf *'
            git url: "https://github.com/jamieabc/${repo}.git", branch: 'master'
            sh "chmod u+x build.sh"
            sh "chmod u+x generate-flatpak.sh"
        }
    }

    stage('Generate flatpak build file') {
        echo 'Generate flatpak build file'
        dir(directory) {
            sh 'generate-flatpak.sh'

            bitmarkd_flatpak = new File(bitmarkd_flatpak_file)
            recorderd_flatpak = new File(recorderd_flatpak_file)
            if (!bitmarkd_flatpak.exists()) {
                error("Fail to generate ${bitmarkd_flatpak_file}")
            }

            if (!recorderd_flatpak.exists()) {
                error("Fail to generate ${recorderd_flatpak_file}")
            }
        }
    }

    stage('Build flatpak bundle') {
        dir(directory) {
            sh "./build.sh ${bitmarkd_flatpak_file} bitmarkd"
            sh "./build.sh ${bitmarkd_flatpak_file} bitmarkd"
        }
    }

    stage('Upload to S3') {
        echo 'Upload to S3'
    }
}
