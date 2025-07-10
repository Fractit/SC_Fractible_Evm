
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockToken is ERC20{

    constructor(address _reciever , uint256 _amount)ERC20("USDC" ,"USDC"){
        _mint(_reciever, _amount);
    }
}
