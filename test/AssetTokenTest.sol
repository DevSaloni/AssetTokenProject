// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol"; 
import "../contracts/AssetToken.sol";
import "../contracts/AssetTokenV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AssetTokenTest is Test {
    AssetToken public assetTokenV1;
    AssetTokenV2 public assetTokenV2;
    ERC1967Proxy public proxy;

    address admin = address(0x1);
    address user = address(0x2);

    uint256 maxSupply = 1_000_000 * 10 ** 18;

    function setUp() public {
        vm.startPrank(admin);

        // Deploy V1 and initialize via proxy
        assetTokenV1 = new AssetToken();
        bytes memory data = abi.encodeWithSelector(
            AssetToken.initialize.selector,
            "Asset Token",
            "AST",
            maxSupply
        );

        proxy = new ERC1967Proxy(address(assetTokenV1), data);

        // Attach V1 interface to proxy
        assetTokenV1 = AssetToken(address(proxy));

        console.log("V1 Proxy deployed and initialized at address:", address(proxy));

        vm.stopPrank();
    }

    function testMintV1() public {
        vm.startPrank(admin);

        // Mint 100 tokens to user
        assetTokenV1.mintTokens(user, 100 * 10 ** 18);

        uint256 balance = assetTokenV1.balanceOf(user);
        assertEq(balance, 100 * 10 ** 18, "User should have 100 tokens");

        // Show balance in CLI
        console.log("User balance after mint V1:", balance);

        vm.stopPrank();
    }

    function testUpgradeToV2AndPause() public {
        vm.startPrank(admin);

        // Mint tokens in this test so balance persists after upgrade
        assetTokenV1.mintTokens(user, 100 * 10 ** 18);
        console.log("User balance before upgrade:", assetTokenV1.balanceOf(user));

        // Deploy V2
        assetTokenV2 = new AssetTokenV2();
        console.log("AssetTokenV2 deployed at address:", address(assetTokenV2));

        // Upgrade proxy to V2 and initialize V2
        bytes memory upgradeData = abi.encodeWithSelector(
            AssetTokenV2.initializeV2.selector
        );

        AssetTokenV2(address(proxy)).upgradeToAndCall(address(assetTokenV2), upgradeData);
        console.log("Proxy upgraded to V2");

        // Attach V2 interface to proxy
        AssetTokenV2 upgraded = AssetTokenV2(address(proxy));

        // Check balance persists
        uint256 balance = upgraded.balanceOf(user);
        console.log("User balance after upgrade:", balance);
        assertEq(balance, 100 * 10 ** 18, "Balance should persist after upgrade");

        // Pause the contract
        upgraded.pause();
        assertEq(upgraded.pausedManually(), true, "Contract should be paused");
        console.log("Contract paused successfully");

        // Attempt transfer should revert
        vm.expectRevert(); 
        upgraded.transfer(address(0x3), 1 * 10 ** 18);
        console.log("Transfer blocked while paused (as expected)");

        vm.stopPrank();
    }
}
