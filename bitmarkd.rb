require_relative "base_build"
require_relative "common_module"

class BitmarkdBuild < BaseBuild
  include Common

  def initialize(tag)
    @tag = tag
  end

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
            "bitmarkd --config-file=./bitmarkd.conf gen-peer-identity",
            "bitmarkd --config-file=./bitmarkd.conf gen-rpc-cert",
            "bitmarkd --config-file=./bitmarkd.conf gen-proof-identity",
            "elif [ $1 ] && [ \"$1\" = 'script' ]; then",
            "shift",
            "$*",
            "elif [ $# -eq 0 ]; then",
            "bitmarkd --config-file=./bitmarkd.conf",
            "fi"
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

  def custom_modules
    modules = preset_common_modules
    version = @tag.delete('v')

    truncated_url = "bitmark-inc/bitmarkd/tar.gz/#{@tag}"
    github_url = "github.com/#{truncated_url}"
    modules.push(module_info(github_url, url_file_shasum(truncated_url)))
    modules.last[:"build-commands"].push(
      "go install -ldflags '-X main.version=#{version}' github.com/bitmark-inc/bitmarkd/command/bitmarkd"
    )
    modules
  end
end

BaseBuild.check_arguments

bitmarkd = BitmarkdBuild.new ARGV[0]
bitmarkd.build
