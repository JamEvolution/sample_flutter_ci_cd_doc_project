#!/bin/bash

# Sample App Distribution Script
# Kullanım: ./scripts/appdistribution.sh
# Çalıştırmadan önce: chmod +x scripts/appdistribution.shn/bash

source scripts/config.sh

function banner() {
  clear
  echo -e "\033[1;36m"
  echo ""
  echo "  ███████╗ █████╗ ███╗   ███╗██████╗ ██╗     ███████╗"
  echo "  ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║     ██╔════╝"
  echo "  ███████╗███████║██╔████╔██║██████╔╝██║     █████╗  "
  echo "  ╚════██║██╔══██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝  "
  echo "  ███████║██║  ██║██║ ╚═╝ ██║██║     ███████╗███████╗"
  echo "  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝"
  echo ""
  echo -e "         \033[1;33mSample App Distribution Script\033[0m"
  echo -e "         \033[1;36m------------------------------\033[0m"
  echo ""
}

function select_platform() {
  echo -e "\033[1;32m1)\033[0m Android (apk)"
  echo -e "\033[1;32m2)\033[0m iOS (ipa)"
  echo -e "\033[1;31m3)\033[0m Çıkış :( "
  echo -ne "\033[1;34mOrtam seçiniz [1-3]: \033[0m"
  read p
  case $p in
    1) platform="android" ;;
    2) platform="ios" ;;
    3) echo -e "\033[1;31mHoşçakal!\033[0m"; exit 0 ;;
    *) echo -e "\033[1;31mLütfen 1-3 arasında bir seçim yapınız.\033[0m"; stop; select_platform ;;
  esac
}

function select_flavor() {
  echo -e "\033[1;32m1)\033[0m dev \033[1;33m--> Geliştirici\033[0m"
  echo -e "\033[1;32m2)\033[0m staging \033[1;33m--> Test\033[0m"
  echo -e "\033[1;32m3)\033[0m prod \033[1;33m--> Canlı\033[0m"
  echo -e "\033[1;31m4)\033[0m Çıkış :( "
  echo -ne "\033[1;34mOrtam (flavor) seçiniz [1-4]: \033[0m"
  read f
  case $f in
    1) flavor="dev" ;;
    2) flavor="staging" ;;
    3) flavor="prod" ;;
    4) echo -e "\033[1;31mHoşçakal! Sample ekip üyesi :)\033[0m"; exit 0 ;;
    *) echo -e "\033[1;31mLütfen 1-4 arasında bir seçim yapınız.\033[0m"; stop; select_flavor ;;
  esac
}

function get_release_notes() {
  echo -ne "\033[1;34mRelease Notu için açıklama giriniz: \033[0m"
  read release_notes
}

function stop() {
  local mesaj="$@"
  [ -z "$mesaj" ] && mesaj="Devam etmek için ENTER tuşuna basınız"
  read -p "$mesaj" readEnterKey
}

function distribute() {
  echo "---- $platform ($flavor) ----"
  if [[ $platform == "android" ]]; then
    fvm flutter build apk --flavor $flavor -t lib/main.dart --release
    find "build/app/outputs/flutter-apk/" -type f -name "app-$flavor-release.apk" -execdir mv {} appdistribution.apk ';'
    apkPath="$(find build/app/outputs/flutter-apk/ -name 'appdistribution.apk')"
    echo "APK yolu: $apkPath"
    appIdVar="${flavor}_androidAppId"
    groupVar="${flavor}_testerGroup"
    firebase appdistribution:distribute $apkPath --app ${!appIdVar} --release-notes "$release_notes" --groups ${!groupVar}
    echo "Success android ($flavor)"
  elif [[ $platform == "ios" ]]; then
    fvm flutter build ipa --flavor $flavor --export-method ad-hoc -t lib/main.dart
    find "build/ios/ipa" -type f -name "*.ipa" -execdir mv {} appdistribution.ipa ';'
    ipaPath="$(find build/ios/ipa -name 'appdistribution.ipa')"
    echo "IPA yolu: $ipaPath"
    appIdVar="${flavor}_iosAppId"
    groupVar="${flavor}_testerGroup"
    firebase appdistribution:distribute $ipaPath --app ${!appIdVar} --release-notes "$release_notes" --groups ${!groupVar}
    echo "Success ios ($flavor)"
  fi
}

set -e

banner
select_platform
select_flavor
get_release_notes
distribute
