// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "./Vm.sol"; // foundry cheat codes
import "./console.sol"; // hardhat console.log - run forge test --verbosity 3

import 'src/Multisig.sol';

contract MultisigTest is DSTest {

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address owner1 = 0xEBcFba9f74a34f7118D1D2C078fCff4719D6518D;
    address owner2 = 0x534347d1766E89dB52C440AF833f0384d861B13E;
    address[] public addrs = [owner1, owner2];
    Multisig multisig;

    function setUp() public {
        multisig = new Multisig(addrs);
    }

    // all tests must start with "test"
    function testSanity() public {
        string memory x = "hello";
        console.log("console.log sanity check");
        assertEq(x, "hello");
    }

    // test constructor

    // test modifiers: onlyOwner, onlyContract
    function testOnlyOwner() public {
        address to = address(0x123);
        uint value = 1;
        bytes memory data;
        uint nNeeded = 2;
        vm.expectRevert("msg.sender is not an owner");
        multisig.createTx(to, value, data, nNeeded);
        vm.prank(owner1);
        multisig.createTx(to, value, data, nNeeded);
        vm.prank(owner2);
        multisig.createTx(to, value, data, nNeeded);
    }
    
    function testOnlyContract() public {
        address newOwner = address(0x123);
        vm.expectRevert("msg.sender is not this contract");
        multisig.addOwner(newOwner);
        vm.prank(address(multisig));
        multisig.addOwner(newOwner);
    }

    // test addOwner, removeOwner, changeOwner
    function testAddOwner() public {
        address newOwner1 = address(0x123);
        address newOwner2 = address(0x456);

        // make sure they aren't already owners
        uint result = 0;
        if (multisig.owners(newOwner1) || multisig.owners(newOwner2)) {
            result = 1;
        }
        assertEq(result, 0, "newOwners already owners");

        vm.startPrank(address(multisig));
        // add an owner
        multisig.addOwner(newOwner1);
        result = 0;
        if (multisig.owners(newOwner1)) {
            result = 1;
        }
        assertEq(result, 1, "newOwner1 is not an owner");

        // add another
        multisig.addOwner(newOwner2);
        result = 0;
        if (multisig.owners(newOwner2)) {
            result = 1;
        }
        assertEq(result, 1, "newOwner2 is not an owner");
        vm.stopPrank();

    }

    function testRemoveOwner() public {

        // make sure they are already owners
        uint result = 0;
        if (multisig.owners(owner1) || multisig.owners(owner2)) {
            result = 1;
        }
        assertEq(result, 1, "Owners to remove are not currently owners");

        vm.startPrank(address(multisig));
        // add an owner
        multisig.removeOwner(owner1);
        result = 0;
        if (multisig.owners(owner1)) {
            result = 1;
        }
        assertEq(result, 0, "removed owner1 is still owner");

        // add another
        multisig.removeOwner(owner2);
        result = 0;
        if (multisig.owners(owner2)) {
            result = 1;
        }
        assertEq(result, 0, "removed owner2 is still owner");
        vm.stopPrank();

    }

    // test createTx, signTx, sendTx
    function testCreateTx() public {
        address to = address(0x123);
        uint value = 1;
        bytes memory data = abi.encode("asdf");
        uint nNeeded = 2;

        bytes32 txHash = keccak256(abi.encodePacked(to, value, data));
        bytes32 pendingHash = keccak256(abi.encodePacked(txHash, nNeeded, block.number));

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);
        assertEq(pendingHashObs, pendingHash, "incorrect pendingHash");

        bytes32 txHashObs;
        uint nNeededObs;
        uint nSignedObs;
        (txHashObs, nNeededObs, nSignedObs) = multisig.pending(pendingHash);
        assertEq(txHashObs, txHash, "incorrect txHash");
        assertEq(nNeededObs, nNeeded, "incorrect nNeeded");
        assertEq(nSignedObs, 1, "nSignedObs != 1");
        uint result = 0; // No assertEq for bools
        if (multisig.getSigner(pendingHashObs, owner1)) {
            result = 1;
        }
        assertEq(result, 1, "createTx did not add signer");
    }

    function testSignTx() public {
        // createTx
        address to = address(0x123);
        uint value = 1;
        bytes memory data = abi.encode("asdf");
        uint nNeeded = 3;

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);

        // try sign with another owner
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);
        
        // check pending hash signers, nSigned
        bytes32 txHashObs;
        uint nNeededObs;
        uint nSignedObs;
        (txHashObs, nNeededObs, nSignedObs) = multisig.pending(pendingHashObs);
        assertEq(nSignedObs, 2, "incorrect nSignedObs");

        uint result = 0; // No assertEq for bools
        if (multisig.getSigner(pendingHashObs, owner1)) {
            result = 1;
        }
        assertEq(result, 1, "signTx did not add signer");

        // sign with already signed owner, check nSigned
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);
        (txHashObs, nNeededObs, nSignedObs) = multisig.pending(pendingHashObs);
        assertEq(nSignedObs, 2, "incorrect nSignedObs");
    }

    function testSignAndSendTx() public {
        // sending eth
        address to = owner1;
        uint value = 30;
        bytes memory data = abi.encode("");
        uint nNeeded = 2;
        uint initialBalance = to.balance;

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);

        // sign
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check sent (immediately)
        assertEq(to.balance, initialBalance + value, "multisig tx failed to send ether");

        // function call
        uint i = 1;
        uint j = 2;
        TestContract testContract = new TestContract(i);
        to = address(testContract);
        value = 0;
        data = abi.encodeWithSignature("callMe(uint256)", j);
        nNeeded = 2;

        vm.prank(owner1);
        pendingHashObs = multisig.createTx(to, value, data, nNeeded);

        // sign
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check sent (immediately)
        assertEq(testContract.i(), i + j, "multisig tx failed to call contract");
        
    }

}

contract TestContract {
    uint public i;

    constructor(uint _i) {
        i = _i;
    }

    function callMe(uint j) public {
        i += j;
    }

}