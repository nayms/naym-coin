// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ILayerZeroEndpointV2 } from "../oapp/interfaces/IOAppCore.sol";

struct OFTStorage {
    //// OFT ////
    address tokenAddress;
    //// OFTCore ////

    // @notice Provides a conversion rate when swapping between denominations of SD and LD
    //      - shareDecimals == SD == shared Decimals
    //      - localDecimals == LD == local decimals
    // @dev Considers that tokens have different decimal amounts on various chains.
    // @dev eg.
    //  For a token
    //      - locally with 4 decimals --> 1.2345 => uint(12345)
    //      - remotely with 2 decimals --> 1.23 => uint(123)
    //      - The conversion rate would be 10 ** (4 - 2) = 100
    //  @dev If you want to send 1.2345 -> (uint 12345), you CANNOT represent that value on the remote,
    //  you can only display 1.23 -> uint(123).
    //  @dev To preserve the dust that would otherwise be lost on that conversion,
    //  we need to unify a denomination that can be represented on ALL chains inside of the OFT mesh
    uint256 decimalConversionRate;
    // Address of an optional contract to inspect both 'message' and 'options'
    address msgInspector;
    //// OAppCore ////
    // The LayerZero endpoint associated with the given OApp
    ILayerZeroEndpointV2 endpoint;
    // Mapping to store peers associated with corresponding endpoints
    mapping(uint32 eid => bytes32 peer) peers;
    //// OAppPreCrimeSimulator ////

    // The address of the preCrime implementation.
    address preCrime;
    //// OAppOptionsType3 ////

    // @dev The "msgType" should be defined in the child contract.
    mapping(uint32 eid => mapping(uint16 msgType => bytes enforcedOption)) enforcedOptions;
}

function oftStorage() pure returns (OFTStorage storage s) {
    bytes32 slot = keccak256("OFT.app.storage");
    assembly {
        s.slot := slot
    }
}

struct ERC20Storage {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowance;
}

function erc20Storage() pure returns (ERC20Storage storage s) {
    bytes32 slot = keccak256("ERC20.app.storage");
    assembly {
        s.slot := slot
    }
}
