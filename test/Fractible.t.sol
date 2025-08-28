// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/fractible.sol";
import "../src/MockToken.sol";

contract CounterTest is Test {
    address public usdc;
    address public dai;
    address public fractible;
    address public owner = 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c;
    address public user = 0xFaBcc4b22fFEa25D01AC23c5d225D7B27CB1B6B8;

    function setUp() public {
        vm.startPrank(owner);
        MockToken mockUsdc = new MockToken(owner, 1000000000e6);
        MockToken mockDai = new MockToken(owner, 1000000000e18);
        Fractible fractibleImpl = new Fractible();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(fractibleImpl),
            abi.encodeWithSelector(
                Fractible.initialize.selector,
                owner,
                address(mockUsdc),
                "FLEET",
                "FLEET",
                100,
                100
            )
        );

        console.log("address of proxy is ", address(proxy));
        console.log("address of impl is ", address(fractibleImpl));
        usdc = address(mockUsdc);
        dai = address(mockDai);
        fractible = address(proxy);
        Fractible(fractible).addDepositToken(usdc);
    }

    function test_deployment() public view {
        console.log("usdc address is ", address(usdc));
        console.log("fractible address is ", address(fractible));
    }

    function test_deposit() public {
        IERC20(usdc).approve(fractible, 100e6);
        Fractible(fractible).deposit(100e6, usdc);
        uint256 balance = Fractible(fractible).balanceOf(owner);
        console.log("balance of owner is ", balance);
        assert(balance == 100e6);
    }

    function test_deposit_notApproved() public {
        IERC20(dai).approve(fractible, 100e18);
        vm.expectRevert();
        Fractible(fractible).deposit(100e18, dai);
    }

    function test_deposit_Approved() public {
        Fractible(fractible).addDepositToken(dai);
        IERC20(dai).approve(fractible, 100e18);
        Fractible(fractible).deposit(100e18, dai);
        uint256 balance = Fractible(fractible).balanceOf(owner);
        console.log("balance of user is ", balance);
        assert(balance == 100e18);
    }

    function test_Deposit_Paused() public {
        Fractible(fractible).pauseUnpauseMint(true);
        IERC20(usdc).approve(fractible, 100e6);
        vm.expectRevert();
        Fractible(fractible).deposit(100e6, usdc);
    }

    function test_Deposit_Pause_Unpause_Admin() public {
        Fractible(fractible).pauseUnpauseMint(true);
        IERC20(usdc).approve(fractible, 100e6);
        vm.expectRevert();
        Fractible(fractible).deposit(100e6, usdc);
        Fractible(fractible).pauseUnpauseMint(false);
        Fractible(fractible).deposit(100e6, usdc);
        uint256 balance = Fractible(fractible).balanceOf(owner);
        console.log("balance of owner is ", balance);
        assert(balance == 100e6);
    }

    function test_Deposit_Pause_Unpause_NotAdmin() public {
        vm.stopPrank();
        vm.prank(address(1));
        vm.expectRevert();
        Fractible(fractible).pauseUnpauseMint(true);
    }

    function test_changePrice_Admin() public {
        Fractible(fractible).changePrice(200, 100);
        uint256 price = Fractible(fractible).price();
        console.log("price is ", price);
        assert(price == 200);
    }

    function test_changePrice_NotAdmin() public {
        vm.stopPrank();
        vm.prank(address(1));
        vm.expectRevert();
        Fractible(fractible).changePrice(200, 100);
    }

    function test_Add_and_Remove_Token_Admin() public {
        Fractible(fractible).removeDepositToken(dai);
        bool isAccepted = Fractible(fractible).depositTokens(dai);
        assert(isAccepted == false);
        Fractible(fractible).addDepositToken(dai);
        isAccepted = Fractible(fractible).depositTokens(dai);
        assert(isAccepted == true);
    }

    function test_Add_and_Remove_Token_NotAdmin() public {
        vm.stopPrank();
        vm.prank(address(1));
        vm.expectRevert();
        Fractible(fractible).removeDepositToken(dai);
        vm.prank(address(1));
        vm.expectRevert();
        Fractible(fractible).addDepositToken(dai);
    }

    function test_claim_Admin() public {
        IERC20(usdc).approve(fractible, 100e6);
        Fractible(fractible).deposit(100e6, usdc);
        uint256 contractBalance = IERC20(usdc).balanceOf(fractible);
        assert(contractBalance == 100e6);
        uint256 claimed = Fractible(fractible).claim(usdc);
        assert(claimed == 100e6);
        contractBalance = IERC20(usdc).balanceOf(fractible);
        assert(contractBalance == 0);
    }

    function test_claim_NotAdmin() public {
        IERC20(usdc).approve(fractible, 100e6);
        Fractible(fractible).deposit(100e6, usdc);
        uint256 contractBalance = IERC20(usdc).balanceOf(fractible);
        assert(contractBalance == 100e6);
        vm.stopPrank();
        vm.prank(address(1));
        vm.expectRevert();
        uint256 claimed = Fractible(fractible).claim(usdc);
    }
}
