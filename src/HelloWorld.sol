// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

contract HelloWorld {
    string private greeting = "Hello World!";
    uint public version = 0;
  
    constructor (string memory _greeting) {
        greeting = _greeting;
    }

    function greet() public view returns(string memory) {
        return greeting;
    }

    function updateGreeting(string memory _greeting) public {
        version += 1;
        greeting = _greeting;
    }
}

