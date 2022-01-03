// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "ds-test/test.sol";
import 'src/Multisig.sol';

contract MultisigTest is DSTest {

    address[] public addrs = [address(this), 0xEBcFba9f74a34f7118D1D2C078fCff4719D6518D, 0x534347d1766E89dB52C440AF833f0384d861B13E];
    Multisig multisig;

    function setUp() public {
        multisig = new Multisig(addrs);
    }

    // all tests must start with "test"
    function testSanity() public {
        string memory x = "hello";
        assertEq(
            x,
            "hello"
        );
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
        uint x = 0;
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
