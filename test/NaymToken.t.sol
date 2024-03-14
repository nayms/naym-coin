// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.20;

import { Test, console as c, Vm } from "forge-std/Test.sol";

import { IERC20Errors } from "openzeppelin/interfaces/draft-IERC6093.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";

import { IDiamondCut } from "lib/diamond-2-hardhat/contracts/interfaces/IDiamondCut.sol";
import { DiamondProxy } from "src/generated/DiamondProxy.sol";
import { IDiamondProxy } from "src/generated/IDiamondProxy.sol";
import { LibDiamondHelper } from "src/generated/LibDiamondHelper.sol";
import { LibGovernance } from "src/libs/LibGovernance.sol";
import { LibHelpers } from "src/libs/LibHelpers.sol";
import { InitDiamond } from "src/init/InitDiamond.sol";
import { NaymsTokenFacet } from "src/facets/NaymsTokenFacet.sol";
import { Modifiers } from "src/shared/Modifiers.sol";
import { StdStyle } from "forge-std/StdStyle.sol";
import { LibConstants as LC } from "src/libs/LibConstants.sol";

contract NaymTokenTest is Test {
    using StdStyle for *;

    address owner1 = address(0x111);
    address owner2 = address(0x789);
    address minter1 = address(0x123);
    address minter2 = address(0x456);
    address user1 = address(0x1234);

    address public naymsAddress;

    IDiamondProxy public t;
    InitDiamond public initDiamond;

    address public deployer;
    address public owner;
    address public systemAdmin;

    function setUp() public {
        c.log("\n -- D01 Deployment Defaults\n");
        c.log("block.chainid", block.chainid);

        bool BOOL_FORK_TEST = vm.envOr({ name: "BOOL_FORK_TEST", defaultValue: false });
        c.log("Are tests being run on a fork?".yellow().bold(), BOOL_FORK_TEST);
        bool TESTS_FORK_UPGRADE_DIAMOND = vm.envOr({ name: "TESTS_FORK_UPGRADE_DIAMOND", defaultValue: true });
        c.log("Are we testing diamond upgrades on a fork?".yellow().bold(), TESTS_FORK_UPGRADE_DIAMOND);

        if (BOOL_FORK_TEST) {
            // uint256 FORK_BLOCK = vm.envOr({
            //     name: string.concat("FORK_BLOCK_", vm.toString(block.chainid)),
            //     defaultValue: type(uint256).max
            // });
            // c.log("FORK_BLOCK", FORK_BLOCK);

            // if (FORK_BLOCK == type(uint256).max) {
            //     c.log(
            //         "Using latest block for fork, consider pinning a block number to avoid overloading the RPC
            // endpoint"
            //     );
            //     vm.createSelectFork(getChain(block.chainid).rpcUrl);
            // } else {
            //     vm.createSelectFork(getChain(block.chainid).rpcUrl, FORK_BLOCK);
            // }

            // naymsAddress = getDiamondAddress();
            // t = IDiamondProxy(naymsAddress);

            // deployer = address(this);
            // owner = t.owner();
            // vm.label(owner, "Owner");
            // systemAdmin = vm.envOr({
            //     name: string.concat("SYSTEM_ADMIN_", vm.toString(block.chainid)),
            //     defaultValue: address(0xE6aD24478bf7E1C0db07f7063A4019C83b1e5929)
            // });
            // vm.label(systemAdmin, "System Admin");

            // vm.startPrank(owner);
            // if (TESTS_FORK_UPGRADE_DIAMOND) {
            //     IDiamondCut.FacetCut[] memory cut = LibDiamondHelper.deployFacetsAndGetCuts(naymsAddress);
            //     scheduleAndUpgradeDiamond(cut);
            // }
        } else {
            c.log("Local testing (no fork)");

            deployer = address(this);
            owner = address(this);
            vm.startPrank(deployer);

            vm.label(owner, "Account 0 (Test Contract address, deployer, owner)");
            systemAdmin = makeAddr("System Admin 0");

            c.log("Deploy diamond");
            naymsAddress = address(new DiamondProxy(owner));
            vm.label(naymsAddress, "Nayms diamond");
            t = IDiamondProxy(naymsAddress);

            // deploy all facets
            IDiamondCut.FacetCut[] memory cuts = LibDiamondHelper.deployFacetsAndGetCuts(address(t));

            initDiamond = new InitDiamond();
            vm.label(address(initDiamond), "InitDiamond");
            c.log("InitDiamond:", address(initDiamond));

            c.log("Cut and init");
            t.diamondCut(cuts, address(initDiamond), abi.encodeCall(InitDiamond.init, (systemAdmin)));

            c.log("Diamond setup complete.");
        }

        vm.stopPrank();
    }

    function test_diamond() public {
        t.name();
    }

    function test_Init() public {
        assertEq(t.name(), "Naym");
        assertEq(t.symbol(), "NAYM");
        assertEq(t.decimals(), 18);
        assertEq(t.totalSupply(), 0);
        assertEq(t.owner(), owner1);
        assertEq(t.minter(), minter1);
    }

    function test_ChangeOwner() public {
        // pass
        vm.prank(systemAdmin);
        t.transferOwnership(owner2);
        assertEq(t.owner(), owner2);

        // not owner
        vm.prank(systemAdmin);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, systemAdmin));
        t.transferOwnership(systemAdmin);

        // invalid new owner
        vm.prank(owner2);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        t.transferOwnership(address(0));
    }

    function test_SetMinter() public {
        // unauthorized
        vm.prank(address(0x1234));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1234)));
        t.setMinter(minter2);

        // authorized
        vm.prank(owner1);
        t.setMinter(minter2);
        assertEq(t.minter(), minter2);

        // can set to null address
        vm.prank(owner1);
        t.setMinter(address(0));
        assertEq(t.minter(), address(0));
    }

    function test_Mint() public {
        // unauthorized
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Modifiers.UnauthorizedMinter.selector, user1));
        t.mint(user1, 100);

        // authorized
        vm.prank(minter1);
        t.mint(user1, 100);
        assertEq(t.totalSupply(), 100);
        assertEq(t.balanceOf(user1), 100);
    }

    function test_Burn() public {
        vm.prank(minter1);
        t.mint(user1, 100);

        // burn more than balance
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user1, 100, 101));
        t.burn(101);

        // burn less than balance
        vm.prank(user1);
        t.burn(50);
        assertEq(t.totalSupply(), 50);
        assertEq(t.balanceOf(user1), 50);
    }

    function scheduleAndUpgradeDiamond(
        IDiamondCut.FacetCut[] memory _cut,
        address _init,
        bytes memory _calldata
    )
        internal
    {
        // 1. schedule upgrade
        // 2. upgrade
        bytes32 upgradeHash = LibGovernance._calculateUpgradeId(_cut, _init, _calldata);
        if (upgradeHash == 0xc597f3eb22d11c46f626cd856bd65e9127b04623d83e442686776a2e3b670bbf) {
            c.log("There are no facets to upgrade. This hash is the keccak256 hash of an empty IDiamondCut.FacetCut[]");
        } else {
            changePrank(systemAdmin);
            t.createUpgrade(upgradeHash);
            changePrank(owner);
            t.diamondCut(_cut, _init, _calldata);
            changePrank(systemAdmin);
        }
    }

    function scheduleAndUpgradeDiamond(IDiamondCut.FacetCut[] memory _cut) internal {
        scheduleAndUpgradeDiamond(_cut, address(0), "");
    }
}
