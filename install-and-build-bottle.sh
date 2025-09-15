#!/bin/bash

macos_codename() {
  case "$(sw_vers -productVersion | cut -d. -f1)" in
    13) echo "ventura" ;;
    14) echo "sonoma" ;;
    15) echo "sequoia" ;;
    26) echo "tahoe" ;;
    *)  echo "unknown" ;;
  esac
}

OS_NAME=$(macos_codename)

brew install --build-bottle anylinuxfs
NEW_BOTTLE_HASH=$(brew bottle anylinuxfs | grep 'sha256 cellar:' | grep -oE '[a-f0-9]{64}')
perl -pi -e 's/sha256 cellar: :any, arm64_'$OS_NAME':( +)"[a-f0-9]{64}"/sha256 cellar: :any, arm64_'$OS_NAME':\1"'$NEW_BOTTLE_HASH'"/' Formula/anylinuxfs.rb
for f in anylinuxfs--*; do mv "$f" $(echo $f | sed 's/--/-/'); done
