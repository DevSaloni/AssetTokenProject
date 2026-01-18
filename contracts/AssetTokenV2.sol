// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./AssetToken.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract AssetTokenV2 is AssetToken, PausableUpgradeable {
    bool public pausedManually;

    function initializeV2() public reinitializer(2) {
        __Pausable_init();
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
        pausedManually = true;
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
        pausedManually = false;
    }

    // Block transfers when paused
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override whenNotPaused {
        super._update(from, to, value);
    }
}
