git submodule update --init --recursive

git config --global --add safe.directory /workspaces/chip-invaders/chipinvaders/librelane

nix profile add nixpkgs#verible
apt install universal-ctags verilator