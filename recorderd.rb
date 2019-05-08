require_relative "base_build"

class RecorderdBuild < BaseBuild
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
            "recorderd --config-file=./recorderd-data/recorderd.conf generate-identity",
            "fi",
            "recorderd --config-file=./recorderd-data/recorderd.conf"
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
    truncated_url = "bitmark-inc/bitmarkd/tar.gz/#{@tag}"
    github_url = "github.com/#{truncated_url}"
    info = module_info(github_url, url_file_shasum(truncated_url))
    info[:"build-commands"].push(
      'go install github.com/bitmark-inc/bitmarkd/command/recorderd'
    )
    info
  end
end

if 1 != ARGV.length
  puts "Please input tag version to build"
  exit false
end

recorderd = RecorderdBuild.new ARGV[0]
recorderd.build
