// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { AppStorage, LibAppStorage } from "../shared/AppStorage.sol";
import { Modifiers } from "../shared/Modifiers.sol";
import { LibHelpers } from "../libs/LibHelpers.sol";
import { LibERC20Token } from "../libs/LibERC20Token.sol";

/**
 * @title Nayms token facet.
 * @notice Use it to access and manipulate Nayms token.
 * @dev Use it to access and manipulate Nayms token.
 */
contract NaymsTokenFacet is Modifiers {
    using LibHelpers for *;

    /**
     * @dev Get total supply of token.
     * @return total supply.
     */
    function totalSupply() external view returns (uint256) {
        return LibERC20Token._totalSupply();
    }

    /**
     * @dev Get token balance of given wallet.
     * @param addr wallet whose balance to get.
     * @return balance of wallet.
     */
    function balanceOf(address addr) external view returns (uint256) {
        return LibERC20Token._balanceOf(addr);
    }

    function name() external pure returns (string memory) {
        return "Naym";
    }

    function symbol() external pure returns (string memory) {
        return "NAYM";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        LibERC20Token._approve(msg.sender, spender, amount, true);

        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.allowance[owner][spender];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        LibERC20Token._transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        LibERC20Token._spendAllowance(from, msg.sender, amount);
        LibERC20Token._transfer(from, to, amount);

        return true;
    }

    /**
     * @dev The minter can mint new tokens.
     * @param _to The address to which the minted tokens will be sent.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external onlyMinter {
        LibERC20Token._mint(_to, _amount);
    }

    /**
     * @dev Burn one's own tokens.
     * @param _amount The amount of tokens to burn.
     */
    function burn(uint256 _amount) external {
        LibERC20Token._burn(msg.sender, _amount);
    }

    function minter() external view returns (address) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.minter;
    }
}
