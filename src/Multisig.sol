// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;


contract Multisig {

    event CreateTx(address to, uint value, bytes data);
    event SignTx(bytes32 pendingHash, address signer);
    event UnsignTx(bytes32 pendingHash, address signer);
    event SendTx(bytes32 txHash);
    event AddOwner(address newOwner);
    event RemoveOwner(address owner);

    struct Transaction {
        address to;
        uint value;
        bytes data;
    }

    struct PendingTx {
        bytes32 txHash;
        uint n_needed;
        uint n_signed;
        mapping (address => bool) signers;
    }

    mapping (address => bool) owners;
    mapping (bytes32 => Transaction) txs;
    mapping (bytes32 => PendingTx) pending;

    constructor (address[] memory initialOwners) {
        for (uint i = 0; i < initialOwners.length; i += 1) {
            owners[initialOwners[i]] = true;
        }
    }

    modifier onlyOwner {
        require(owners[msg.sender]);
        _;
    }

    // internal functions that need multisig sign off
    modifier onlyContract {
        require(msg.sender == address(this));
        _;
    }

    /// @notice Adds an owner
    function addOwner(address newOwner) public onlyContract {
        // Add an owner
        // Log event
    }

    /// @notice Removes current owner
    function removeOwner(address owner) public onlyContract {
        // Remove owner
        // Log event
    }

    function changeOwner(address currOwner, address newOwner) public onlyContract {
        removeOwner(currOwner);
        addOwner(newOwner);
    }

    /// @notice Initialize a transaction and be the first signer
    function createTx(address to, uint value, bytes memory data) public onlyOwner returns (bytes32) {
        // create Transaction
        // create PendingTx
        // signTx
        // log event
    }

    /// @notice Sign off on a transaction and execute it if enough signatures
    function signTx(bytes32 pendingHash) public onlyOwner {
        // sign tx
        // log event
    }

    function unsignTx(bytes32 pendingHash) public onlyOwner {
        // remove signature from tx
    }

    /// @notice Wrapper to send transaction once approved
    /// @param txHash hash that maps to the tx
    function sendTx(bytes32 txHash) private {
        // get transaction data from txHash map
        // call transaction
        // log event
    }

}

