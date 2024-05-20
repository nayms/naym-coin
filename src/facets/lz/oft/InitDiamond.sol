// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { OFTStorage, oftStorage } from "./OFTStorage.sol";

import { ILayerZeroEndpointV2 } from "../oapp/interfaces/IOAppCore.sol";
import { IOFT } from "./interfaces/IOFT.sol";

import { LibOFTConstants } from "./LibOFTConstants.sol";

struct Init {
    address endpoint;
    address delegate;
}

contract InitDiamond {
    function init(Init calldata data) public {
        OFTStorage storage s = oftStorage();

        s.endpoint = ILayerZeroEndpointV2(data.endpoint);
        s.endpoint.setDelegate(data.delegate);

        // note: when delegatecalling into InitDiamond, address(this) is the diamond address.
        s.tokenAddress = address(this);

        // @param _localDecimals The decimals of the token on the local chain (this chain).
        // decimalConversionRate = 10 ** (_localDecimals - sharedDecimals());
        uint8 sharedDecimals = 6;
        if (LibOFTConstants.DECIMALS < sharedDecimals) revert IOFT.InvalidLocalDecimals();
        s.decimalConversionRate = 10 ** (LibOFTConstants.DECIMALS - sharedDecimals);
    }
}
