# chip-invaders
DYC26

## Getting started
Open the repo in the Devcontainer.

### Running the librelane flow
1. Open a librelane nix-shell.
```sh
nix-shell librelane/
```

2. To run the flow:
```sh
cd chipinvaders/
make librelane
```

3. To view the results:
```sh
make view-results
```

### Building and loading onto an FPGA
1. Start the xc7 dev env.
```sh
nix develop github:openxc7/toolchain-nix
```

2. To build the bitstream:
```sh
cd chipinvaders/
make bits
```

3. To load onto the FPGA:
```sh
make program
```