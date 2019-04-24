require "ap"
require "json"
require "open-uri"
require_relative "base_build"

BITMARKD_GO_MOD_FILE =
  "https://raw.githubusercontent.com" \
  "/bitmark-inc" \
  "/bitmarkd" \
  "/master/go.mod".freeze
TMP_FILE = "test".freeze
GITHUB_DOWNLOAD_SITE = "https://codeload.github.com".freeze
APP_PATH = "/app/src/github.com".freeze
OUTPUT_JSON_FILE = "com.bitmark.bitmarkd.json".freeze

def constants
  {
    "app-id": "com.bitmark.bitmarkd",
    "runtime": "org.freedesktop.Platform",
    "sdk": "org.freedesktop.Sdk",
    "runtime-version": "1.6",
    "cleanup": [
      "/usr/lib/sdk/golang",
      "/app/src"
    ],
    "command": "run.sh",
    "finish-args": [
      "--share=network",
      "--filesystem=~/bitmarkd-data:create"
    ],
    "modules": [
      run_script,
      golang_module
    ]
  }
end

def golang_module
  {
    "name": "golang",
    "buildsystem": "simple",
    "sources": [
      {
        "type": "archive",
        "url": "https://dl.google.com/go/go1.12.4.linux-amd64.tar.gz",
        "sha256": "d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5"
      }
    ],
    "build-commands": [
      "install -d /app",
      "cp -rpv * /app"
    ]
  }
end

def run_script
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

# generate hash with key: package name, value: sha-256 value
def parse_go_module
  hsh = {}
  open(BITMARKD_GO_MOD_FILE) do |file|
    file.each do |line|
      truncated = line.strip.gsub(" // indirect", "")
      next unless /^(github|golang)/.match? truncated

      package, version = extract_info truncated
      url = package + "/tar.gz/" + version
      download_file url
      hash = sha256
      remove_tmp_file
      hsh[url] = hash
    end
  end
  remove_tmp_file
  hsh
end

def remove_tmp_file
  `rm #{TMP_FILE}` if File.file?(TMP_FILE)
end

def extract_info(str)
  package, version = str.split(" ")
  if compound_version? version
    commit_hash = version.split("-").last
    return [package, commit_hash]
  end
  [package, version]
end

def compound_version?(str)
  str.split("-").size > 1
end

def download_file(path)
  github_download_url = "https://codeload.github.com/"
  actual_path = path.gsub("github.com/", "").gsub("golang.org/x", "golang")
  url = github_download_url + actual_path
  puts "download url: #{url}"
  `curl -LJ #{url} -o #{TMP_FILE}`
  sleep 1
end

def sha256
  `shasum -a 256 #{TMP_FILE}`.split(" ").first
end

def github_download_url(full_path)
  path = full_path
  path = path.gsub("golang.org/x", "golang") if %r{golang.org/x}.match? path
  path = path.gsub("github.com/", "")
  GITHUB_DOWNLOAD_SITE + "/#{path}"
end

def extracted_directory_name(repo, version)
  # v1.2 will be changed into to 1.2, v is removed
  return "#{repo}-#{version[1..-1]}" if /^v\d+/.match? version

  "#{repo}-#{version}"
end

flatpak = constants

parse_go_module.each do |full_path, sha|
  _, organization, repo, _, version = full_path.split("/")
  dir = extracted_directory_name(repo, version)
  module_info = {
    "name": repo,
    "sources": [
      {
        "type": "file",
        "url": github_download_url(full_path),
        "sha256": sha
      }
    ],
    "buildsystem": "simple",
    "build-commands": [
      "tar zxf #{version}",
      "mkdir -p #{APP_PATH}/#{organization}",
      "mv #{dir} #{APP_PATH}/#{organization}/#{repo}"
    ]
  }
  flatpak[:modules].push(module_info)
end

File.open(OUTPUT_JSON_FILE, 'w') do |file|
  file.write(JSON.pretty_generate(flatpak, indent: "  ", object_nl: "\n"))
end
