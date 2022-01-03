// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "ds-test/test.sol";
import 'src/Multisig.sol';

contract MultisigTest is DSTest {

    address[] public addrs = [0xEBcFba9f74a34f7118D1D2C078fCff4719D6518D, 0x534347d1766E89dB52C440AF833f0384d861B13E];
    Multisig multisig;

    function setUp() public {
        multisig = new Multisig(addrs);
    }

}
