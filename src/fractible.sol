// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fractible is ERC20 {
    address public owner;

    address public depositToken;
    uint256 public constant price = 1;
    uint256 public max_mint;

    bool public pause;

    uint8 decimal;

    constructor(
        address _owner,
        address _depositToken,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _decimal,
        uint256 _maxMint
    ) ERC20(_tokenName, _tokenSymbol) {
        owner = _owner;
        depositToken = _depositToken;
        max_mint = _maxMint;
        decimal = _decimal;
        pause = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }

    function deposit(uint256 _amount) public returns (uint256) {
        uint256 current_supply = totalSupply();

        require(current_supply + _amount <= max_mint, "Deposit more than Max");
        IERC20(depositToken).transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, _amount);

        return _amount;
    }

    function pauseWithdraw(bool _pause) public {
        require(msg.sender == owner, "You are not the Owner");
        pause = _pause;
    }

    function withdraw(uint256 _amount) public returns (uint256) {
        require(!pause, "Withdrawals are paused");
        uint256 userBalance = balanceOf(msg.sender);
        require(_amount >= userBalance, "Withdrawing more than Balance");
        _burn(msg.sender, _amount);

        IERC20(depositToken).transfer(msg.sender, _amount);

        return _amount;
    }

    function claim() public returns (uint256) {
        require(msg.sender == owner, "You are not the Owner");
        uint256 contractBalance = IERC20(depositToken).balanceOf(address(this));

        IERC20(depositToken).transfer(owner, contractBalance);

        return contractBalance;
    }
}
