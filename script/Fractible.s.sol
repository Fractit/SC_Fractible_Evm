// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script, console} from "forge-std/Script.sol";
// import {Fractible} from "../src/fractible.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract FractibleScript is Script {
//     address public pUsd = 0xdddD73F5Df1F0DC31373357beAC77545dC5A6f3F;
//     address public fvh;

//     function setUp() public {}

//     function run() public {
//         uint256 privateKey = vm.envUint("PVT_KEY");
//         address deployer = vm.addr(privateKey);
//         console.log("deployer is", deployer);

//         vm.startBroadcast(privateKey);
//         Fractible fr_contract = new Fractible(deployer, pUsd, "FLEET", "FLEET", 6);
//         fvh = address(fr_contract);

//         console.log("address of contract is ", address(fvh));
//         vm.stopBroadcast();
//     }
// }

// // forge script script/Fractible.s.sol --rpc-url https://rpc.ankr.com/botanix_mainnet --broadcast -vvv --legacy --slow
// // https://node.botanixlabs.dev
// //https://rpc.plume.org
