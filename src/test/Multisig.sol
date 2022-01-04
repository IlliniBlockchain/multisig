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
        multisig.addOwner(newOwner);
        vm.prank(address(multisig));
        multisig.addOwner(newOwner);
    }

    // test addOwner, removeOwner, changeOwner

    // test createTx, signTx, sendTx
    function testCreateTx() public {
        address to = address(0x123);
        uint value = 1;
        bytes memory data;
        vm.prank(owner1);
        multisig.createTx(to, value, data);
    }

}
