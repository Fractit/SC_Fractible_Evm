// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/fractible.sol";
import "../src/MockToken.sol";

contract CounterTest is Test {
    address public usdc;
    address public fractible;
    address public owner = 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c;
    address public user = 0xFaBcc4b22fFEa25D01AC23c5d225D7B27CB1B6B8;

    function setUp() public {
        vm.startPrank(owner);
        MockToken mockUsdc = new MockToken(owner, 1000000000e6);
        Fractible fractibleContract = new Fractible(owner, address(mockUsdc), "FVH", "FVH", 18);
        usdc = address(mockUsdc);
        fractible = address(fractibleContract);
    }

    function test_deployment() public {
        console.log("usdc address is ", address(usdc));
        console.log("fractible address is ", address(fractible));
    }

    function test_deposit() public {
        IERC20(usdc).approve(fractible, 100e27);
        Fractible(fractible).deposit(1000e6);
        uint256 fracitbleBalance = IERC20(fractible).balanceOf(owner);
        uint256 usdcBalance = IERC20(usdc).balanceOf(owner);
        console.log("Fractilbe balance is", fracitbleBalance);
        console.log("usdc balance is", usdcBalance);
    }

    function test_withdraw() public {
        test_deposit();
        Fractible(fractible).withdraw(1000e6);
        uint256 fracitbleBalance = IERC20(fractible).balanceOf(owner);
        uint256 usdcBalance = IERC20(usdc).balanceOf(owner);
        console.log("Fractilbe balance is", fracitbleBalance);
        console.log("usdc balance is", usdcBalance);
    }

    function test_claim() public {
        test_deposit();
        Fractible(fractible).claim();
        uint256 fracitbleBalance = IERC20(fractible).balanceOf(owner);
        uint256 usdcBalance = IERC20(usdc).balanceOf(owner);
        console.log("Fractilbe balance is", fracitbleBalance);
        console.log("usdc balance is", usdcBalance);
    }

    function test_claimNotOwner() public {
        test_deposit();
        vm.stopPrank();
        vm.startPrank(user);
        vm.expectRevert();
        Fractible(fractible).claim();
        uint256 fracitbleBalance = IERC20(fractible).balanceOf(owner);
        uint256 usdcBalance = IERC20(usdc).balanceOf(owner);
        console.log("Fractilbe balance is", fracitbleBalance);
        console.log("usdc balance is", usdcBalance);
    }
}
