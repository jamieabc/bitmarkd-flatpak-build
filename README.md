This repository aims to auto generate flatpak json build file for go module.

It targets `bitmarkd` repository, parses its go module file then generates corresponding flatpak json file.

* Usage

    Genearate bitmarkd/recordred flatpak json file:

    ```
    ruby bitmarkd.rb
    ruby recorderd.rb
    ```

    Build flatpak bundle:

    ```
    build.sh com.bitmark.bitmarkd.json bitmarkd
    build.sh com.bitmark.recorderd.json recorderd
    ```
