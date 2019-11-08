require_relative "base_build"
require_relative "common_module"

class RecorderdBuild < BaseBuild
  include Common

  def initialize(tag)
    @tag = tag
  end

  def app_id
    "com.bitmark.recorderd"
  end

  def finish_args
    [
      "--share=network",
      "--filesystem=~/recorderd-data:create"
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
            "recorderd --config-file=./recorderd.conf generate-identity",
            "elif [ $1 ] && [ \"$1\" != '--init' ]; then",
            "recorderd $*",
            "elif [ $# -eq 0 ]; then",
            "recorderd --config-file=./recorderd.conf",
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
    "com.bitmark.recorderd.json"
  end

  def custom_modules
    modules = preset_common_modules
    version = @tag

    truncated_url = "bitmark-inc/bitmarkd/tar.gz/#{@tag}"
    github_url = "github.com/#{truncated_url}"
    modules.push(module_info(github_url, url_file_shasum(truncated_url)))
    modules.last[:"build-commands"].push(
      "go install -ldflags '-X main.version=#{version}' github.com/bitmark-inc/bitmarkd/command/recorderd"
    )
    modules
  end
end

BaseBuild.check_arguments

recorderd = RecorderdBuild.new ARGV[0]
recorderd.build
