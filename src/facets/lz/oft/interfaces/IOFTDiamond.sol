// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IOFTFacet.sol";
import "./IERC20Facet.sol";
import "diamond-2-hardhat/interfaces/IDiamondCut.sol";
import "diamond-2-hardhat/interfaces/IDiamondLoupe.sol";
import "diamond-2-hardhat/interfaces/IERC165.sol";
import "diamond-2-hardhat/interfaces/IERC173.sol";

import { SendParam } from "../OFTCoreFacet.sol";

interface IOFTFacetMock {
    function debit(
        uint256 _amountToSendLD,
        uint256 _minAmountToCreditLD,
        uint32 _dstEid
    )
        external
        returns (uint256 amountDebitedLD, uint256 amountToCreditLD);

    function debitView(
        uint256 _amountToSendLD,
        uint256 _minAmountToCreditLD,
        uint32 _dstEid
    )
        external
        view
        returns (uint256 amountDebitedLD, uint256 amountToCreditLD);

    function removeDust(uint256 _amountLD) external view returns (uint256 amountLD);

    function toLD(uint64 _amountSD) external view returns (uint256 amountLD);

    function toSD(uint256 _amountLD) external view returns (uint64 amountSD);
    function credit(
        address _to,
        uint256 _amountToCreditLD,
        uint32 _srcEid
    )
        external
        returns (uint256 amountReceivedLD);

    function buildMsgAndOptions(
        SendParam calldata _sendParam,
        uint256 _amountToCreditLD
    )
        external
        view
        returns (bytes memory message, bytes memory options);
}

interface IOFTDiamond is IOFTFacet, IERC20Facet, IDiamondCut, IDiamondLoupe, IERC165, IOFTFacetMock { }
