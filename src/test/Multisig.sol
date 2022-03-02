// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "./Vm.sol"; // foundry cheat codes
import "./console.sol"; // hardhat console.log - run forge test --verbosity 3

import "src/Multisig.sol";

contract MultisigTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address owner1 = 0xEBcFba9f74a34f7118D1D2C078fCff4719D6518D;
    address owner2 = 0x534347d1766E89dB52C440AF833f0384d861B13E;
    address[] public addrs = [owner1, owner2];
    uint256 nNeeded = 2;
    Multisig multisig;

    function setUp() public {
        multisig = new Multisig(addrs, nNeeded);
    }

    // all tests must start with "test"
    function testSanity() public {
        string memory x = "hello";
        console.log("console.log sanity check");
        assertEq(x, "hello");
    }

    // test constructor
    function testConstructor() public {
        uint256 hasOwner;
        for (uint256 i = 0; i < addrs.length; i++) {
            hasOwner = multisig.owners(addrs[i]) ? 1 : 0;
            assertEq(hasOwner, 1);
        }
        assertEq(multisig.nOwners(), addrs.length);
        assertEq(multisig.nNeeded(), nNeeded);
    }

    // test modifiers: onlyOwner, onlyContract, validNumNeeded
    function testOnlyOwner() public {
        address to = address(0x123);
        uint256 value = 1;
        bytes memory data;
        vm.expectRevert("msg.sender is not an owner");
        multisig.createTx(to, value, data);
        vm.prank(owner1);
        multisig.createTx(to, value, data);
        vm.prank(owner2);
        multisig.createTx(to, value, data);
    }

    function testOnlyContract() public {
        address newOwner = address(0x123);
        vm.expectRevert("msg.sender is not this contract");
        vm.prank(owner1);
        multisig.addOwner(newOwner);
        vm.prank(address(multisig));
        multisig.addOwner(newOwner);
    }

    function testValidNumNeeded() public {
        address newOwner = address(0x123);
        // nOwners and nNeeded are currently 2
        vm.startPrank(address(multisig));
        vm.expectRevert("invalid number of owners or needed signers");
        multisig.removeOwner(newOwner);

        multisig.addOwner(newOwner);
        multisig.removeOwner(newOwner);
    }

    // test changeNumNeeded
    function testChangeNumNeeded() public {
        vm.startPrank(address(multisig));

        multisig.addOwner(address(0x123));

        // Change to 3
        uint256 newN = 3;
        multisig.changeNumNeeded(newN);
        assertEq(multisig.nNeeded(), newN);

        // Change to 4 (> nOwners)
        vm.expectRevert("invalid number of owners or needed signers");
        multisig.changeNumNeeded(4);

        // Change back
        multisig.changeNumNeeded(nNeeded);
        assertEq(multisig.nNeeded(), nNeeded);
    }

    // test addOwner, removeOwner, changeOwner
    function testAddOwner() public {
        address newOwner1 = address(0x123);
        address newOwner2 = address(0x456);

        // make sure they aren't already owners
        uint256 result = 0;
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

        // Check that the owner cannot be added again
        vm.expectRevert("specified address is already an owner");
        multisig.addOwner(newOwner1);

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
        uint256 result = 0;
        if (multisig.owners(owner1) || multisig.owners(owner2)) {
            result = 1;
        }
        assertEq(result, 1, "Owners to remove are not currently owners");

        vm.startPrank(address(multisig));
        vm.expectRevert("invalid number of owners or needed signers");
        multisig.removeOwner(owner1);

        // Add owners to satisfy nNeeded
        multisig.addOwner(address(0x123));
        multisig.addOwner(address(0x456));

        // remove an owner
        multisig.removeOwner(owner1);
        result = 0;
        if (multisig.owners(owner1)) {
            result = 1;
        }
        assertEq(result, 0, "removed owner1 is still owner");

        // Check that the owner cannot be removed again
        vm.expectRevert("specified address is not an owner");
        multisig.removeOwner(owner1);

        // remove another
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
        uint256 value = 1;
        bytes memory data = abi.encode("asdf");

        bytes32 txHash = keccak256(abi.encodePacked(to, value, data));
        bytes32 pendingHash = keccak256(abi.encodePacked(txHash, block.number));

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data);
        assertEq(pendingHashObs, pendingHash, "incorrect pendingHash");

        bytes32 txHashObs;
        uint256 nSignedObs;
        (txHashObs, nSignedObs) = multisig.pending(pendingHash);
        assertEq(txHashObs, txHash, "incorrect txHash");
        assertEq(nSignedObs, 1, "nSignedObs != 1");
        uint256 result = 0; // No assertEq for bools
        if (multisig.getSigner(pendingHashObs, owner1)) {
            result = 1;
        }
        assertEq(result, 1, "createTx did not add signer");
    }

    function testSignTx() public {
        // createTx
        address to = address(0x123);
        uint256 value = 1;
        bytes memory data = abi.encode("asdf");

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data);

        // try sign with another owner
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check pending hash signers, nSigned
        bytes32 txHashObs;
        uint256 nSignedObs;
        (txHashObs, nSignedObs) = multisig.pending(pendingHashObs);
        assertEq(nSignedObs, 2, "incorrect nSignedObs");

        uint256 result = 0; // No assertEq for bools
        if (multisig.getSigner(pendingHashObs, owner2)) {
            result = 1;
        }
        assertEq(result, 1, "signTx did not add signer");

        // sign with already signed owner, check nSigned
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);
        (txHashObs, nSignedObs) = multisig.pending(pendingHashObs);
        assertEq(nSignedObs, 2, "incorrect nSignedObs");
    }

    function testSignAndSendTx() public {
        // sending eth
        address to = owner1;
        uint256 value = 30;
        bytes memory data = abi.encode("");
        uint256 nNeeded = 2;

        // set multisig to have some ether in it
        vm.deal(address(multisig), 50000);

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);
        uint256 initialBalance = to.balance;

        // sign
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check sent (immediately)
        assertEq(
            to.balance,
            initialBalance + value,
            "multisig tx failed to send ether"
        );

        // function call
        uint256 i = 1;
        uint256 j = 2;
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
        assertEq(
            testContract.i(),
            i + j,
            "multisig tx failed to call contract"
        );
    }

    // FUZZING TESTS
    // test modifiers: onlyOwner, onlyContract
    function testOnlyOwnerWithFuzzing(
        address to,
        uint256 value,
        bytes memory data,
        uint256 nNeeded
    ) public {
        vm.expectRevert("msg.sender is not an owner");
        multisig.createTx(to, value, data, nNeeded);
        vm.prank(owner1);
        multisig.createTx(to, value, data, nNeeded);
        vm.prank(owner2);
        multisig.createTx(to, value, data, nNeeded);
    }

    function testOnlyContractWithFuzzing(address newOwner) public {
        vm.expectRevert("msg.sender is not this contract");
        multisig.addOwner(newOwner);
        vm.prank(address(multisig));
        multisig.addOwner(newOwner);
    }

    // test createTx, signTx, sendTx
    function testCreateTxWithFuzzing(
        address to,
        uint256 value,
        bytes memory data,
        uint256 nNeeded
    ) public {
        bytes32 txHash = keccak256(abi.encodePacked(to, value, data));
        bytes32 pendingHash = keccak256(
            abi.encodePacked(txHash, nNeeded, block.number)
        );

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);
        assertEq(pendingHashObs, pendingHash, "incorrect pendingHash");

        bytes32 txHashObs;
        uint256 nNeededObs;
        uint256 nSignedObs;
        (txHashObs, nNeededObs, nSignedObs) = multisig.pending(pendingHash);
        assertEq(txHashObs, txHash, "incorrect txHash");
        assertEq(nNeededObs, nNeeded, "incorrect nNeeded");
        assertEq(nSignedObs, 1, "nSignedObs != 1");
        uint256 result = 0; // No assertEq for bools
        if (multisig.getSigner(pendingHashObs, owner1)) {
            result = 1;
        }
        assertEq(result, 1, "createTx did not add signer");
    }

    function testSignTxWithFuzzing(
        address to,
        uint256 value,
        bytes memory data,
        uint256 nNeeded
    ) public {
        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data, nNeeded);

        // try sign with another owner
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check pending hash signers, nSigned
        bytes32 txHashObs;
        uint256 nNeededObs;
        uint256 nSignedObs;
        (txHashObs, nNeededObs, nSignedObs) = multisig.pending(pendingHashObs);
        assertEq(nSignedObs, 2, "incorrect nSignedObs");

        uint256 result = 0; // No assertEq for bools
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

    function testSignAndSendTxWithFuzzing(
        address to,
        uint256 value,
        bytes memory data,
        uint256 nNeeded
    ) public {
        // sending eth
        uint256 initialBalance = to.balance;

        vm.prank(owner1);
        bytes32 pendingHashObs = multisig.createTx(to, value, data);

        // sign
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check sent (immediately)
        assertEq(
            to.balance,
            initialBalance + value,
            "multisig tx failed to send ether"
        );

        // function call
        uint256 i = 1;
        uint256 j = 2;
        TestContract testContract = new TestContract(i);
        to = address(testContract);
        value = 0;
        data = abi.encodeWithSignature("callMe(uint256)", j);

        vm.prank(owner1);
        pendingHashObs = multisig.createTx(to, value, data);

        // sign
        vm.prank(owner2);
        multisig.signTx(pendingHashObs);

        // check sent (immediately)
        assertEq(
            testContract.i(),
            i + j,
            "multisig tx failed to call contract"
        );
    }
}

contract TestContract {
    uint256 public i;

    constructor(uint256 _i) {
        i = _i;
    }

    function callMe(uint256 j) public {
        i += j;
    }
}
