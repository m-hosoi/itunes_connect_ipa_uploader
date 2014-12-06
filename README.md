itunes_connect_ipa_uploader
====
## Description
iTunes Connectにipaファイルをアップロードするコマンド

パスワードはKeyChainから取得する

## Install
    sudo cp ipa_uploader.swift /usr/bin/ipa_uploader
    sudo chmod a+x /usr/bin/ipa_uploader
  
## Usage
    ipa_uploader -u username -f path_to.ipa
