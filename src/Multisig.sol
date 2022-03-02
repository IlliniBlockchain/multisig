// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

/// @title Multisig wallet
/// @author Illini Blockchain
/// @notice A simple implementation of a multisig wallet
contract Multisig {
    /// EVENTS
    /// Use events to log data about interaction with the multisig - consumable by clients
    event CreateTx(
        address to,
        uint256 value,
        bytes data,
        bytes32 txHash,
        bytes32 pendingHash
    );
    event SignTx(bytes32 pendingHash, address signer);
    event UnsignTx(bytes32 pendingHash, address signer);
    event SendTx(bytes32 pendingHash);
    event AddOwner(address newOwner);
    event RemoveOwner(address owner);
    event NumNeededChange(uint256 numNeeded);

    /// STRUCTS
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
    }

    struct PendingTx {
        bytes32 txHash;
        uint256 nSigned;
        mapping(address => bool) signers;
    }

    /// CONTRACT STATE
    mapping(address => bool) public owners;
    mapping(bytes32 => Transaction) public txs;
    mapping(bytes32 => PendingTx) public pending;
    uint256 public nOwners;
    uint256 public nNeeded;

    /// MODIFIERS
    /// Functions with this modifier can only be called by an owner
    modifier onlyOwner() {
        require(owners[msg.sender], "msg.sender is not an owner");
        _;
    }

    /** To add or remove an owner, we may want multiple people to sign off
        similar to another multisig tx. We can make those functions public
        and use this modifier to allow us to use our built-in multisig
        functionality to extend to these functions.
     */
    modifier onlyContract() {
        require(msg.sender == address(this), "msg.sender is not this contract");
        _;
    }

    // Functions with this modifier can only be called with a valid number
    // of needed signatures with respect to the number of owners
    modifier validNumNeeded(uint256 ownerCount, uint256 _nNeeded) {
        require(
            _nNeeded <= ownerCount && _nNeeded != 0 && ownerCount != 0,
            "invalid number of owners or needed signers"
        );
        _;
    }

    /// FUNCTIONS

    /// @notice Helper function to view PendingTx signers from test contract
    function getSigner(bytes32 pendingHash, address signer)
        external
        view
        returns (bool)
    {
        return pending[pendingHash].signers[signer];
    }

    /// @notice Initialize multisig with initial owners
    /// @param initialOwners List of addresses of owners
    /// @param _nNeeded Number of owners needed to sign
    constructor(address[] memory initialOwners, uint256 _nNeeded)
        validNumNeeded(initialOwners.length, _nNeeded)
    {
        nOwners = initialOwners.length;
        for (uint256 i = 0; i < nOwners; i += 1) {
            owners[initialOwners[i]] = true;
        }
        nNeeded = _nNeeded;
    }

    function changeNumNeeded(uint256 _nNeeded)
        public
        validNumNeeded(nOwners, _nNeeded)
    {
        nNeeded = _nNeeded;
        emit NumNeededChange(nNeeded);
    }

    /// @notice Adds a new owner
    /// @param newOwner Address of owner to add
    function addOwner(address newOwner) public onlyContract {
        require(!owners[newOwner], "specified address is already an owner");
        // Add an owner
        owners[newOwner] = true;
        nOwners += 1;
        // Log event
        emit AddOwner(newOwner);
    }

    /// @notice Removes existing owner
    /// @param owner Address of existing owner to remove
    function removeOwner(address owner)
        public
        onlyContract
        validNumNeeded(nOwners - 1, nNeeded)
    {
        require(owners[owner], "specified address is not an owner");
        // Remove owner
        delete owners[owner];
        nOwners -= 1;
        // Log event
        emit RemoveOwner(owner);
    }

    /// @notice AddOwner and removeOwner in one transaction
    /// @param currOwner Address of owner to remove
    /// @param newOwner Address of owner to add
    function changeOwner(address currOwner, address newOwner)
        public
        onlyContract
    {
        // TODO: This checks that nNeeded is valid which doesn't
        // make sense for just replacing an Owner.
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
    function createTx(
        address to,
        uint256 value,
        bytes memory data
    ) public onlyOwner returns (bytes32) {
        // create Transaction
        bytes32 txHash = keccak256(abi.encodePacked(to, value, data));
        txs[txHash] = Transaction({to: to, value: value, data: data});

        // create PendingTx
        bytes32 pendingHash = keccak256(abi.encodePacked(txHash, block.number));
        PendingTx storage pendingTx = pending[pendingHash];
        pendingTx.txHash = txHash;
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
        require(pendingTx.nSigned > 0, "Transaction does not exist!");
        if (!pendingTx.signers[msg.sender]) {
            pendingTx.signers[msg.sender] = true;
            pendingTx.nSigned += 1;
        }
        if (pending[pendingHash].nSigned >= nNeeded) {
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
    /// @param pendingHash Hash that maps to the Transaction
    function sendTx(bytes32 pendingHash) private {
        // get transaction data from txHash map
        PendingTx storage pendingTx = pending[pendingHash];
        Transaction storage txn = txs[pendingTx.txHash];

        // call transaction
        (bool sent, bytes memory data) = txn.to.call{value: txn.value}(
            txn.data
        );

        require(sent, "Failed to send transaction");

        // log event
        emit SendTx(pendingHash);
    }
}
