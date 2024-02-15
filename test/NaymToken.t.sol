// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";

import { NaymToken } from "../src/NaymToken.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";

contract NaymTokenTest is Test {
    NaymToken public t;

    address owner1 = address(0x111);
    address owner2 = address(0x789);
    address minter1 = address(0x123);
    address minter2 = address(0x456);

    function setUp() public {
        t = new NaymToken(owner1, minter1);
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
        vm.prank(owner1);
        t.transferOwnership(owner2);
        assertEq(t.owner(), owner2);

        // not owner
        vm.prank(owner1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner1));
        t.transferOwnership(owner1);

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
        vm.prank(address(0x1234));
        vm.expectRevert(abi.encodeWithSelector(NaymToken.UnauthorizedMinter.selector, address(0x1234)));
        t.mint(address(0x1234), 100);

        // authorized
        vm.prank(minter1);
        t.mint(address(0x1234), 100);
        assertEq(t.totalSupply(), 100);
        assertEq(t.balanceOf(address(0x1234)), 100);
    }
}
