// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "ds-test/test.sol";
import 'src/HelloWorld.sol';

contract HelloWorldTest is DSTest {
    HelloWorld hello;
    function setUp() public {
      hello = new HelloWorld("Foundry is fast!");
    }

    function test1() public {
        assertEq(
            hello.greet(),
            "Foundry is fast!"
        );
    }

    function test2(string memory _greeting) public {
        assertEq(hello.version(), 0);
        hello.updateGreeting(_greeting);
        assertEq(hello.version(), 1);
        assertEq(
            hello.greet(),
            _greeting
        );
    }
}
