// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import { IOFT, SendParam, OFTReceipt } from "./IOFT.sol";
import { MessagingFee, MessagingReceipt } from "../OFTCoreFacet.sol";
import { IOAppOptionsType3, EnforcedOptionParam } from "../../oapp/libs/OAppOptionsType3Facet.sol";

interface IOFTFacet {
    struct InboundPacket {
        Origin origin;
        uint32 dstEid;
        address receiver;
        bytes32 guid;
        uint256 value;
        address executor;
        bytes message;
        bytes extraData;
    }

    struct OFTFeeDetail {
        int256 feeAmountLD;
        string description;
    }

    struct OFTLimit {
        uint256 minAmountLD;
        uint256 maxAmountLD;
    }

    struct Origin {
        uint32 srcEid;
        bytes32 sender;
        uint64 nonce;
    }

    function SEND() external pure returns (uint16);
    function SEND_AND_CALL() external pure returns (uint16);
    function msgInspector() external view returns (address);
    function allowInitializePath(Origin memory origin) external view returns (bool);
    function approvalRequired() external pure returns (bool);
    function combineOptions(
        uint32 _eid,
        uint16 _msgType,
        bytes memory _extraOptions
    )
        external
        view
        returns (bytes memory);
    function composeMsgSender() external view returns (address sender);
    function decimalConversionRate() external view returns (uint256);
    function endpoint() external view returns (address);
    function enforcedOptions(uint32 _eid, uint16 _msgType) external view returns (bytes memory);
    function isPeer(uint32 _eid, bytes32 _peer) external view returns (bool);
    function lzReceive(
        Origin memory _origin,
        bytes32 _guid,
        bytes memory _message,
        address _executor,
        bytes memory _extraData
    )
        external
        payable;
    function lzReceiveAndRevert(InboundPacket[] memory _packets) external payable;
    function lzReceiveSimulate(
        Origin memory _origin,
        bytes32 _guid,
        bytes memory _message,
        address _executor,
        bytes memory _extraData
    )
        external
        payable;
    function nextNonce(uint32, bytes32) external view returns (uint64 nonce);
    function oApp() external view returns (address);
    function oAppVersion() external pure returns (uint64 senderVersion, uint64 receiverVersion);
    function oftVersion() external pure returns (bytes4 interfaceId, uint64 version);
    function owner() external view returns (address);
    function peers(uint32 _eid) external view returns (bytes32 peer);
    function preCrime() external view returns (address);
    function quoteOFT(SendParam memory _sendParam)
        external
        view
        returns (OFTLimit memory oftLimit, OFTFeeDetail[] memory oftFeeDetails, OFTReceipt memory oftReceipt);
    function quoteSend(
        SendParam memory _sendParam,
        bool _payInLzToken
    )
        external
        view
        returns (MessagingFee memory msgFee);
    function renounceOwnership() external;
    function send(
        SendParam memory _sendParam,
        MessagingFee memory _fee,
        address _refundAddress
    )
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt);
    function setDelegate(address _delegate) external;
    function setEnforcedOptions(EnforcedOptionParam[] memory _enforcedOptions) external;
    function setMsgInspector(address _msgInspector) external;
    function setPeer(uint32 _eid, bytes32 _peer) external;
    function setPreCrime(address _preCrime) external;
    function sharedDecimals() external pure returns (uint8);
    function token() external pure returns (address);
}
