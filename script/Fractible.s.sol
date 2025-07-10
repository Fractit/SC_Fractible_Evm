// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Fractible} from "../src/fractible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FractibleScript is Script {
    address public pUsd = 0x42725b4D9270CFe24F6852401fdDa88248CB4dE9;
    address public fvh;

    function setUp() public {}

    function run() public {
        uint256 privateKey = 0x1;
        address deployer = vm.addr(privateKey);
        console.log("deployer is", deployer);

        vm.startBroadcast(privateKey);
        Fractible fr_contract = new Fractible(
            deployer,
            pUsd,
            "UFDLEB",
            "UFDLEB",
            18,
            150000e18
        );
        fvh = address(fr_contract);

        console.log("address of contract is ", address(fvh));
        vm.stopBroadcast();
        vm.startPrank(0xCf56CD0B43075BbCf4d5C20Aa2A6FfF5bf30c408);

        IERC20(pUsd).approve(fvh, 10000e18);
        Fractible(fvh).deposit(1e18);
        uint256 pusdBalance = IERC20(pUsd).balanceOf(
            0xCf56CD0B43075BbCf4d5C20Aa2A6FfF5bf30c408
        );
        uint256 fractibleBalance = Fractible(fvh).balanceOf(
            0xCf56CD0B43075BbCf4d5C20Aa2A6FfF5bf30c408
        );

        console.log("new pusd balance is ", pusdBalance);
        console.log("new fractible balance is ", fractibleBalance);
    }
}

// forge script script/Fractible.s.sol --rpc-url https://rpc.ankr.com/botanix_mainnet --broadcast -vvv --legacy --slow
// https://node.botanixlabs.dev
//https://rpc.plume.org
