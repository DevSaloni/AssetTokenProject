// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract AssetToken is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER = keccak256("MINTER_ROLE"); // Who can mint tokens

    uint256 public maximumTokens; // Maximum number of tokens allowed

    error MaxSupplyExceeded(); 

    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 maxTokens
    ) public initializer {
        __ERC20_init(tokenName, tokenSymbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();

        maximumTokens = maxTokens;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); 
        _grantRole(MINTER, msg.sender);             
    }

    function mintTokens(address recipient, uint256 amount) external onlyRole(MINTER) {
        if (totalSupply() + amount > maximumTokens) {
            revert MaxSupplyExceeded();
        }

        _mint(recipient, amount);
    }

    function _authorizeUpgrade(address newLogic)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
