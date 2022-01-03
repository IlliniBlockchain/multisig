<h1 align="center">Multisig</h1>

### Description
Our own implementation of a multisig wallet for organization fund management.

### Stack
Foundry. This is a pretty basic isolated application so I figured it would be a good project to test out Paradigm's new Solidity development framework. You can read  more about the reasoning behind this framework in [their article](https://www.paradigm.xyz/2021/12/introducing-the-foundry-ethereum-development-toolbox/).

In the future we'll probably use a combination of hardhat and foundry, but I (Alec) haven't figured out how to combine them yet.

### Setup locally
1. Install [Rust](https://www.rust-lang.org/tools/install). It's a prerequisite for Foundry.

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. Install [Foundry](https://github.com/gakonst/foundry).

    1. Install forge.
    
    ```
    cargo install --git https://github.com/gakonst/foundry --bin forge --locked
    ```
    
    2. Install cast. (not totally necessary atm but a nice-to-have)
    
    ```
    cargo install --git https://github.com/gakonst/foundry --bin cast
    ```
3. You're ready to go!

### Basic commands
```
forge test
forge build
forge create
forge verify-contract
```
For more information, run any of these commands with flag `-h`, or run `forge -h`.
