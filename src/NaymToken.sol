// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.20;

import { ERC20 } from "openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";

contract NaymToken is ERC20, Ownable {
  /**
   * @dev The caller account is not authorized to mint.
   */
  error UnauthorizedMinter(address account);

  /**
   * @dev The minter can mint new tokens.
   */
  address public minter;

  /**
   * @dev Throws if called by any account other than the minter.
   */
  modifier onlyMinter() {
      if(_msgSender() != minter) {
        revert UnauthorizedMinter(_msgSender());
      }
      _;
  }

  /**
   * @dev Constructor
   * @param _owner The address of the initial owner of the contract.
   * @param _minter The address of the initial minter of the contract.
   */
  constructor(address _owner, address _minter) ERC20("Naym", "NAYM") Ownable(_owner) {
    minter = _minter;
  }

  /**
   * @dev The owner can set the minter.
   * @param _minter The address of the new minter.
   */
  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }

  /**
   * @dev The minter can mint new tokens.
   * @param _to The address to which the minted tokens will be sent.
   * @param _amount The amount of tokens to mint.
   */
  function mint(address _to, uint256 _amount) public onlyMinter {
    _mint(_to, _amount);
  }

  /**
   * @dev Burn one's own tokens.
   * @param _amount The amount of tokens to burn.
   */
  function burn(uint256 _amount) public {
    _burn(_msgSender(), _amount);
  }
}
