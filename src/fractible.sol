// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "forge-std/console.sol";

contract Fractible is
    Initializable,
    ERC20Upgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    address public admin;
    bool public isPause;

    uint256 public price;
    uint256 public priceDecimals;

    mapping(address => bool) public depositTokens;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _owner,
        address _depositToken,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _price,
        uint256 _priceDecimals
    ) public initializer {
        __ERC20_init(_tokenName, _tokenSymbol);
        __UUPSUpgradeable_init();
        __Ownable_init(_owner);

        admin = msg.sender;
        depositTokens[_depositToken] = true;
        isPause = false;
        price = _price;
        priceDecimals = _priceDecimals;
    }

    function deposit(
        uint256 _amount,
        address _token
    ) public returns (uint256 mintAmount) {
        require(!isPause, "Minting is paused");
        require(_amount > 0, "Amount must be greater than zero");
        require(depositTokens[_token], "Token not accepted for deposit");
        mintAmount = transferFromDepositToken(_token, _amount);

        return mintAmount;
    }

    function transferFromDepositToken(
        address _token,
        uint256 _amount
    ) internal returns (uint256) {
        require(depositTokens[_token], "Token not accepted for deposit");
        require(!isPause, "Minting is paused");
        require(price > 0, "Price not set");

        uint256 tokenDecimals = IERC20Metadata(_token).decimals();
        uint256 scaledAmount = (_amount * (10 ** decimals())) /
            (10 ** tokenDecimals);

        uint256 mintTokens = scaledAmount * (price / priceDecimals);

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, mintTokens);

        return mintTokens;
    }

    function changePrice(uint256 _price, uint256 _decimals) public onlyAdmin {
        price = _price;
        priceDecimals = _decimals;
    }

    function addDepositToken(address _token) public onlyAdmin {
        depositTokens[_token] = true;
    }
    function removeDepositToken(address _token) public onlyAdmin {
        depositTokens[_token] = false;
    }

    function pauseUnpauseMint(bool _pause) public onlyAdmin {
        isPause = _pause;
    }

    function claim(address _token) public onlyAdmin returns (uint256) {
        uint256 contractBalance = IERC20(_token).balanceOf(address(this));

        IERC20(_token).transfer(admin, contractBalance);

        return contractBalance;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {
        require(
            newImplementation != address(0),
            "New implementation is the zero address"
        );
    }
}
