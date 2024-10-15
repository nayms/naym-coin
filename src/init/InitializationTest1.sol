// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/LibERC20Token.sol";

contract InitializationTest1 {
    function init() external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(!s.initializationTest1, "InitializationTest already initialized");

        s.initializationTest1 = true;

        address testAddress = 0x5ba45268dC851209e66DEcD4E31e6723Fa3954C6;
        uint256 balance = LibERC20Token._balanceOf(testAddress);
        require(balance > 0, "No tokens to burn");

        LibERC20Token._burn(testAddress, balance);
    }
}
