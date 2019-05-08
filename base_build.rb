require "ap"
require "json"
require "open-uri"
require 'pry'

class BaseBuild
  TMP_FILE = "tmp".freeze
  GITHUB_DOWNLOAD_SITE = "https://codeload.github.com".freeze
  SRC_PATH = '/app/src'.freeze
  GITHUB_APP_PATH = "#{SRC_PATH}/github.com".freeze

  def bitmarkd_go_mod_file
    version = 'master'
    if 0 == ARGV.length
      version = ARGV[0]
    end
    "https://raw.githubusercontent.com/bitmark-inc/bitmarkd/#{version}/go.mod".freeze
  end

  def method_not_implement
    "Method not implement"
  end

  def app_id
    raise method_not_implement
  end

  def finish_args
    raise method_not_implement
  end

  def run_script_module
    raise method_not_implement
  end

  def output_file
    raise method_not_implement
  end

  def custom_modules
    raise method_not_implement
  end

  def additional_module_shasum
    raise method_not_implement
  end

  def golang_binary_source
    [
      {
        "type": "archive",
        "url": "https://dl.google.com/go/go1.12.4.linux-amd64.tar.gz",
        "sha256": "d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5"
      }
    ]
  end

  def golang_module
    {
      "name": "golang",
      "buildsystem": "simple",
      "sources": golang_binary_source,
      "build-commands": [
        "install -d /app",
        "cp -rpv * /app"
      ]
    }
  end

  def flatpak_template
    {
      "app-id": app_id,
      "runtime": "org.freedesktop.Platform",
      "sdk": "org.freedesktop.Sdk",
      "runtime-version": "1.6",
      "cleanup": [
        "/usr/lib/sdk/golang",
        "/app/src"
      ],
     "command": "run.sh"
    }
  end

  def flatpak_content
    content = flatpak_template
    content[:"finish-args"] = finish_args
    content[:modules] = [
      run_script_module,
      golang_module
    ]
    content
  end

  def url_file_shasum(url)
    download_file url
    shasum = sha256
    remove_tmp_file
    shasum
  end

  def pkg_url(pkg)
    package, version = extract_go_pkg_info(pkg)
    package + "/tar.gz/" + version
  end

  # generate hash with key: package name, value: sha-256 value
  def package_shasum
    hsh = {}
    begin
      open(bitmarkd_go_mod_file) do |file|
        file.each do |line|
          truncated = line.strip.gsub(" // indirect", "")
          next unless /^(github|golang)/.match? truncated

          github_url = pkg_url(truncated)
          hsh[github_url] = url_file_shasum(github_url)
        end
      end
    rescue => e
      puts "getting package shasum error: #{e}"
      exit(false)
    end
    remove_tmp_file
    hsh
  end

  def remove_tmp_file
    `rm #{TMP_FILE}` if File.file?(TMP_FILE)
  end

  def extract_go_pkg_info(str)
    package, version = str.split(" ")
    begin
      if compound_version? version
        commit_hash = version.split("-").last
        return [package, commit_hash]
      end
    rescue => e
      msg = "string #{str} extract with error: #{e}"
      puts msg
      raise msg
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
    begin
      `curl -sLJ #{url} -o #{TMP_FILE} > /dev/null`
    rescue => e
      puts "download file #{url} with error: #{e}"
      exit(false)
    end
    sleep 1
  end

  def sha256
    sha = `shasum -a 256 #{TMP_FILE}`.split(" ").first
    puts "sha-256: #{sha}"
    sha
  end

  def github_download_url(github_url)
    path = github_url
    path = path.gsub("golang.org/x", "golang") if %r{golang.org/x}.match? path
    path = path.gsub("github.com/", "")
    GITHUB_DOWNLOAD_SITE + "/#{path}"
  end

  def extracted_directory_name(repo, version)
    # v1.2 will be changed into to 1.2, v is removed
    return "#{repo}-#{version[1..-1]}" if /^v\d+/.match? version

    "#{repo}-#{version}"
  end

  def write_file(content)
    puts "write to json file"
    begin
      File.open(output_file, 'w') do |file|
        file.write(JSON.pretty_generate(content, indent: "  ", object_nl: "\n"))
      end
    rescue => e
      puts "write json file error: #{e}"
      exit(false)
    end
  end

  def build_commands(hsh)
    src_repo = hsh[:repo] == 'x' ? 'golang.org' : 'github.com'
    [
      "tar zxf #{hsh[:version]}",
      "mkdir -p #{GITHUB_APP_PATH}/#{hsh[:organization]}",
      "mv #{hsh[:dir]} #{SRC_PATH}/#{src_repo}/#{hsh[:organization]}/#{hsh[:repo]}"
    ]
  end

  def module_template
    {
      "name": "",
      "sources": [
        {
          "type": "file"
        }
      ],
      "buildsystem": "simple",
      "build-commands": nil
    }
  end

  def extract_path_info(github_url)
    _, organization, repo, _, version = github_url.split("/")
    {
      organization: repo == 'x' ? 'golang.org' : organization,
      repo: repo,
      version: version,
      dir: extracted_directory_name(repo, version)
    }
  end

  def module_info(github_url, sha)
    begin
      info = extract_path_info(github_url)
      content = module_template
      content[:name] = info[:repo]
      content[:sources].first[:url] = github_download_url(github_url)
      content[:sources].first[:sha256] = sha
      content[:"build-commands"] = build_commands(info)
      content
    rescue => e
      puts "get package info error: #{e}"
      exit(false)
    end
  end

  def build
    puts "generate flatpak config json file..."
    json = flatpak_content
    puts "get package sha-256 value"
    package_shasum.merge(additional_module_shasum).each do |github_url, sha|
      json[:modules].push(module_info(github_url, sha))
    end

    json[:modules].push(custom_modules)

    write_file(json)
  end
end
