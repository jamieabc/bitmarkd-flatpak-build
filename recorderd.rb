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
end

recorderd = RecorderdBuild.new
recorderd.build
