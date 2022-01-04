// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "./Vm.sol"; // foundry cheat codes
import "./console.sol"; // hardhat console.log - run forge test --verbosity 3

import 'src/Multisig.sol';

contract MultisigTest is DSTest {

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address[] public addrs = [address(this), 0xEBcFba9f74a34f7118D1D2C078fCff4719D6518D, 0x534347d1766E89dB52C440AF833f0384d861B13E];
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

    // test modifiers: onlyOwner, onlyContract
    function testOnlyOwner() public {
        // assertEq doesn't work for bools rn...
        uint result = 0;
        // non-owner
        if (multisig.owners(address(0x123))) {
            result = 1;
        }
        assertEq(result, 0);
        // owner
        result = 0;
        if (multisig.owners(addrs[0])) {
            result = 1;
        }
        assertEq(result, 1);
    }

    // test createTx
    function testCreateTx() public {
        address to = address(0x123);
        uint value = 1;
        bytes memory data;
        multisig.createTx(to, value, data);
    }

    // test signTx
    // test confirm

}
