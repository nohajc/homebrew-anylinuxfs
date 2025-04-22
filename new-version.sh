#!/bin/bash

NEW_VERSION=$1

if [ -z "$NEW_VERSION" ]; then
  echo "Usage: $0 <new_version>"
  exit 1
fi

perl -pi -e 's/VERSION = "[^"]+"/VERSION = "'$NEW_VERSION'"/' Formula/anylinuxfs.rb

URL=$(sed -n '6s/.*url "\(.*\)"/\1/p' Formula/anylinuxfs.rb)
# Replace the VERSION placeholder in the URL
UPDATED_URL=$(echo "$URL" | sed "s/v#{VERSION}/v$NEW_VERSION/")

# Download the file and calculate the SHA256 checksum
echo "Downloading: $UPDATED_URL"
SHA256=$(curl -L "$UPDATED_URL" | sha256)

# Update the sha256 value in the formula
perl -pi -e 's/^  sha256 "[a-f0-9]{64}"/  sha256 "'$SHA256'"/' Formula/anylinuxfs.rb
