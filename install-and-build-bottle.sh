#!/bin/bash

brew install --build-bottle anylinuxfs
NEW_BOTTLE_HASH=$(brew bottle anylinuxfs | grep 'sha256 cellar:' | grep -oE '[a-f0-9]{64}')
perl -pi -e 's/sha256 cellar: :any, arm64_sequoia: "[a-f0-9]{64}"/sha256 cellar: :any, arm64_sequoia: "'$NEW_BOTTLE_HASH'"/' Formula/anylinuxfs.rb
for f in anylinuxfs--*; do mv "$f" $(echo $f | sed 's/--/-/'); done
