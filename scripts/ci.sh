#!/bin/bash

set -x

echo "Install dependencies"
rotrieve install

echo "Run linting and formatting"
roblox-cli analyze --project default.project.json
selene modules
stylua -c modules

echo "Run tests"
lest
