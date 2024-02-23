// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.20;

import { Vm } from "forge-std/Vm.sol";
import { Script, console2 as c } from "forge-std/Script.sol";
import { NaymToken } from "src/NaymToken.sol";

contract Deploy is Script {
  bytes32 internal constant CREATE2_SALT = keccak256("JigzawNFT.deployment.salt");

  function run() public {
    address wallet = msg.sender;
    c.log("Wallet:", wallet);

    address expectedAddr = vm.computeCreate2Address(
      CREATE2_SALT, 
      hashInitCode(type(NaymToken).creationCode, abi.encode(wallet, wallet))
    );

    if (expectedAddr.code.length > 0) {
      c.log("!!!! NaymToken already deployed at:", expectedAddr);
      revert();
    }

    c.log("NaymToken will be deployed at:", expectedAddr);

    vm.startBroadcast(wallet);

    NaymToken t = new NaymToken{salt: CREATE2_SALT}(wallet, wallet);

    c.log("NaymToken deployed at:", address(t));
    
    vm.stopBroadcast();        
  }
}
