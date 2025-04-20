#!/bin/bash

brew install --build-bottle anylinuxfs
brew bottle anylinuxfs
for f in anylinuxfs--*; do mv "$f" $(echo $f | sed 's/--/-/'); done
