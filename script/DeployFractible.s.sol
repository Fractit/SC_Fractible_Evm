// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Fractible} from "../src/fractible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/MockToken.sol";

contract FractibleScript is Script {
    address public usdc = 0xe19cE0aCF70DBD7ff9Cb80715f84aB0Fd72B57AC;
    address public fleet;

    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        console.log("deployer is", deployer);
        vm.startBroadcast(privateKey);
        Fractible fractibleImpl = new Fractible();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(fractibleImpl),
            abi.encodeWithSelector(
                Fractible.initialize.selector,
                deployer,
                usdc,
                "FLEET",
                "FLEET",
                100,
                100
            )
        );
        fleet = address(proxy);

        console.log("address of proxy is ", address(proxy));
        console.log("address of impl is ", address(fractibleImpl));
        console.log("address of contract is ", address(fleet));
        vm.stopBroadcast();
    }
}

// forge script script/DeployFractible.s.sol --rpc-url https://rpc.ankr.com/botanix_testnet --broadcast -vvv --legacy --slow
// https://node.botanixlabs.dev https://rpc.ankr.com/botanix_testnet
