// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Fractible} from "../src/fractible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Claim is Script {
    address public pUsd = 0xdddD73F5Df1F0DC31373357beAC77545dC5A6f3F;
    Fractible public fvh = Fractible(0x618608Ae57ca16Ca6B3A4A08F8ab6144DCD887b8);

    function setUp() public {}

    function run() public {
        uint256 privateKey = 0x1;
        address deployer = vm.addr(privateKey);
        console.log("deployer is", deployer);

        vm.startBroadcast(privateKey);
        uint256 pusdBalance = IERC20(pUsd).balanceOf(deployer);
        console.log("pusd balance is ", pusdBalance);
        fvh.claim();
        pusdBalance = IERC20(pUsd).balanceOf(deployer);
        console.log("new pusd balance is ", pusdBalance);
    }
}

// forge script script/Claim.s.sol --rpc-url https://rpc.plume.org --broadcast -vvv --legacy --slow
// https://node.botanixlabs.dev
//https://rpc.plume.org
