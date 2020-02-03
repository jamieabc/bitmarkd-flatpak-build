module Common
  def libargon2_module
    {
      name: 'libargon2',
      sources: [
        {
          type: "file",
          url: "https://codeload.github.com/P-H-C/phc-winner-argon2/tar.gz/20171227",
          sha256: "eaea0172c1f4ee4550d1b6c9ce01aab8d1ab66b4207776aa67991eb5872fdcd8"
        }
      ],
      buildsystem: "simple",
      'build-commands': [
        "tar zxf 20171227",
        "cd phc-winner-argon2-20171227 && make OPTTARGET=generic && make test",
        "cd phc-winner-argon2-20171227 && make install PREFIX=/app",
        "cd phc-winner-argon2-20171227 && sed -i -- 's/usr/app/g' libargon2.pc",
        "cd phc-winner-argon2-20171227 && sed -i -- 's/\\/@HOST_MULTIARCH@//g' libargon2.pc",
        "cd phc-winner-argon2-20171227 && sed -i -- 's/@UPSTREAM_VER@/20171227/g' libargon2.pc",
        "cd phc-winner-argon2-20171227 && sed -i -- 's/Cflags:/Cflags: -I${includedir}/g' libargon2.pc",
        "cd phc-winner-argon2-20171227 && mkdir -p /app/lib/pkgconfig",
        "cd phc-winner-argon2-20171227 && cp libargon2.pc /app/lib/pkgconfig"
      ]
    }
  end

  def zeromq4_module
    {
      name: "zeromq4",
      sources: [
        {
          type: "archive",
          url: "https://github.com/zeromq/libzmq/releases/download/v4.2.5/zeromq-4.2.5.tar.gz",
          sha256: "cc9090ba35713d59bb2f7d7965f877036c49c5558ea0c290b0dcc6f2a17e489f"
        }
      ],
      buildsystem: "simple",
      'build-commands': [
        "./configure --prefix=/app",
        "make install"
      ]
    }
  end

  def go_env_setup
    {
      name: "goenv-setup",
      sources: [
        {
          type: "script",
          commands: [
            "export GOROOT=/app",
            "export PATH=$PATH:$GOROOT/bin",
            "export GOPATH=/app"
          ],
          'dest-filename': "enable.sh"
        }
      ],
      buildsystem: "simple",
      'build-commands': [
        "cp enable.sh /app"
      ]
    }
  end

  def preset_common_modules
    [
      libargon2_module,
      zeromq4_module,
      go_env_setup
    ]
  end

  def additional_module_shasum
    hsh = {}
    [
      'github.com/cihub/seelog v0.0.0-20170130134532-f561c5e57575',
      'github.com/btcsuite/btcutil v0.0.0-20190425235716-9e5f4b9a998d',
      'github.com/btcsuite/go-socks v0.0.0-20170105172521-4720035b7bfd',
      'github.com/btcsuite/btclog v0.0.0-20170628155309-84c8d2346e9f',
      'github.com/davecgh/go-spew v0.0.0-20171005155431-ecdeabc65495',
      'github.com/golang/protobuf v1.2.0'
    ].each do |m|
      github_url = pkg_url(m)
      hsh[github_url] = url_file_shasum(github_url)
    end
    hsh
  end
end