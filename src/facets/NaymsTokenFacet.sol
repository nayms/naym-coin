// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AppStorage, LibAppStorage} from "../shared/AppStorage.sol";
import {Modifiers} from "../shared/Modifiers.sol";
import {LibHelpers} from "../libs/LibHelpers.sol";
import {LibERC20Token} from "../libs/LibERC20Token.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Nayms token facet.
 * @notice Use it to access and manipulate Nayms token.
 * @dev Use it to access and manipulate Nayms token.
 */
contract NaymsTokenFacet is Modifiers {
    using LibHelpers for *;

    error ERC20PermitDeadlineExpired();
    error ERC20PermitInvalidSignature();

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

    /// @dev The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if (block.timestamp > _deadline) {
            revert ERC20PermitDeadlineExpired();
        }

        bytes32 structHash =
            keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, s.nonces[_owner]++, _deadline));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));

        address signer = ECDSA.recover(digest, _v, _r, _s);
        if (signer == address(0) || signer != _owner) {
            revert ERC20PermitInvalidSignature();
        }

        LibERC20Token._approve(_owner, _spender, _value, true);
    }

    /**
     * @dev Returns the current nonce for `owner`. This value must be included whenever a signature is generated for
     * {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.nonces[owner];
    }

    bytes32 public constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    bytes32 public constant NAYM_TYPEHASH = keccak256(bytes("Naym"));
    bytes32 public constant VERSION_TYPEHASH = keccak256(bytes("1"));

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return
            keccak256(abi.encode(EIP712DOMAIN_TYPEHASH, NAYM_TYPEHASH, VERSION_TYPEHASH, block.chainid, address(this)));
    }
}
