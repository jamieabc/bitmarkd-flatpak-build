require_relative "base_build"

class BitmarkdBuild < BaseBuild
  def app_id
    "com.bitmark.bitmarkd"
  end

  def finish_args
    [
      "--share=network",
      "--filesystem=~/bitmarkd-data:create"
    ]
  end

  def run_script_module
    {
      "name": "run",
      "sources": [
        {
          "type": "script",
          "commands": [
            "if [ $1 ] && [ \"$1\" = '--init' ]; then",
            "bitmarkd --config-file=./bitmarkd-data/bitmarkd.conf gen-peer-identity",
            "bitmarkd --config-file=./bitmarkd-data/bitmarkd.conf gen-rpc-cert",
            "bitmarkd --config-file=./bitmarkd-data/bitmarkd.conf gen-proof-identity",
            "fi",
            "bitmarkd --config-file=./bitmarkd-data/bitmarkd.conf"
          ],
          "dest-filename": "run.sh"
        }
      ],
      "buildsystem": "simple",
      "build-commands": [
        "mkdir -p /app/bin",
        "install run.sh /app/bin/"
      ]
    }
  end

  def output_file
    "com.bitmark.bitmarkd.json"
  end
end

bitmarkd = BitmarkdBuild.new
bitmarkd.build
