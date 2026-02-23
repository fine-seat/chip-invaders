#!/bin/bash

git config --global --add safe.directory '*'
git submodule update --init --recursive
export NIX_CONFIG="connect-timeout = 60
stalled-download-timeout = 300"
nix profile add nixpkgs#verible
apt install -y universal-ctags verilator iverilog
