require_relative "base_build"

class BitmarkdBuild < BaseBuild
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

  def additional_module_shasum
    hsh = {}
    [
      'github.com/cihub/seelog v0.0.0-20170130134532-f561c5e57575'
    ].each do |m|
      github_url = pkg_url(m)
      hsh[github_url] = url_file_shasum(github_url)
    end
    hsh
  end

  def custom_modules
    truncated_url = "bitmark-inc/bitmarkd/tar.gz/#{@tag}"
    github_url = "github.com/#{truncated_url}"
    info = module_info(github_url, url_file_shasum(truncated_url))
    info[:"build-commands"].push(
      'go install github.com/bitmark-inc/bitmarkd/command/bitmarkd'
    )
    info
  end
end

if 1 != ARGV.length
  puts "Please input tag version to build"
  exit false
end

bitmarkd = BitmarkdBuild.new ARGV[0]
bitmarkd.build
