// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

/// @title Multisig wallet
/// @author Illini Blockchain
/// @notice A simple implementation of a multisig wallet
contract Multisig {

    /// EVENTS
    /// Use events to log data about interaction with the multisig - consumable by clients
    event CreateTx(address to, uint value, bytes data, bytes32 txHash, bytes32 pendingHash);
    event SignTx(bytes32 pendingHash, address signer);
    event UnsignTx(bytes32 pendingHash, address signer);
    event SendTx(bytes32 txHash);
    event AddOwner(address newOwner);
    event RemoveOwner(address owner);

    /// STRUCTS
    struct Transaction {
        address to;
        uint value;
        bytes data;
    }

    struct PendingTx {
        bytes32 txHash;
        uint nNeeded;
        uint nSigned;
        mapping (address => bool) signers;
    }

    /// CONTRACT STATE
    mapping (address => bool) public owners;
    mapping (bytes32 => Transaction) public txs;
    mapping (bytes32 => PendingTx) public pending;

    /// MODIFIERS
    /// Functions with this modifier can only be called by an owner
    modifier onlyOwner {
        require(owners[msg.sender], "msg.sender is not an owner");
        _;
    }

    /** To add or remove an owner, we may want multiple people to sign off
        similar to another multisig tx. We can make those functions public
        and use this modifier to allow us to use our built-in multisig
        functionality to extend to these functions.
     */
    modifier onlyContract {
        require(msg.sender == address(this), "msg.sender is not this contract");
        _;
    }

    /// FUNCTIONS

    /// @notice Helper function to view PendingTx signers from test contract
    function getSigner(bytes32 pendingHash, address signer) external view returns (bool) {
        return pending[pendingHash].signers[signer];
    }

    /// @notice Initialize multisig with initial owners
    /// @param initialOwners List of addresses of owners
    constructor (address[] memory initialOwners) {
        for (uint i = 0; i < initialOwners.length; i += 1) {
            owners[initialOwners[i]] = true;
        }
    }

    /// @notice Adds a new owner
    /// @param newOwner Address of owner to add
    function addOwner(address newOwner) public onlyContract {
        // Add an owner
        // Log event
    }

    /// @notice Removes existing owner
    /// @param owner Address of existing owner to remove
    function removeOwner(address owner) public onlyContract {
        // Remove owner
        // Log event
    }

    /// @notice AddOwner and removeOwner in one transaction
    /// @param currOwner Address of owner to remove
    /// @param newOwner Address of owner to add
    function changeOwner(address currOwner, address newOwner) public onlyContract {
        removeOwner(currOwner);
        addOwner(newOwner);
    }

    /// @notice Initialize a transaction and adds first signature
    /// @dev Create tx and pending hash using keccak256(abi.encodePacked(...))
    /// @dev Include block.number to differentiate pendingHash's with same data
    /// @param to Address to send transaction to
    /// @param value Amount in wei (eth/1e18) to send
    /// @param data Transaction data
    /// @return pendingHash for the created tx
    function createTx(address to, uint value, bytes memory data, uint nNeeded) public onlyOwner returns (bytes32) {

        // create Transaction
        bytes32 txHash = keccak256(abi.encodePacked(to, value, data));
        txs[txHash] = Transaction({ to: to, value: value, data: data });

        // create PendingTx
        bytes32 pendingHash = keccak256(abi.encodePacked(txHash, nNeeded, block.number));
        PendingTx storage pendingTx = pending[pendingHash];
        pendingTx.txHash = txHash;
        pendingTx.nNeeded = nNeeded;
        pendingTx.nSigned = 0;

        // log event
        emit CreateTx(to, value, data, txHash, pendingHash);

        // signTx
        pendingTx.signers[msg.sender] = true;
        pendingTx.nSigned += 1;

        return pendingHash;
    }

    /// @notice Signs off on a transaction and execute it if enough signatures
    /// @param pendingHash Hash that maps to the PendingTx to unsign 
    function signTx(bytes32 pendingHash) public onlyOwner {
        // sign tx
        // log event
        // sendTx if enough sigs
        PendingTx storage pendingTx = pending[pendingHash];
        require(pendingTx.nSigned > 0, 'Transaction does not exist!');
        if (!pendingTx.signers[msg.sender]) {
            pendingTx.signers[msg.sender] = true;
            pendingTx.nSigned += 1;
        }
        if (pending[pendingHash].nSigned >= pending[pendingHash].nNeeded) {
            sendTx(pendingHash);
            emit SignTx(pendingHash, msg.sender);
        }
    }

    /// @notice Removes existing signature from a PendingTx
    /// @dev Check if they're signature exists to properly update nSigned
    /// @param pendingHash Hash that maps to the PendingTx to unsign
    function unsignTx(bytes32 pendingHash) public onlyOwner {
        // remove signature from tx
        // log event
    }

    /// @notice Wrapper to send transaction once approved
    /// @param txHash Hash that maps to the Transaction
    function sendTx(bytes32 txHash) private {
        // get transaction data from txHash map
        // call transaction
        // log event
    }

}