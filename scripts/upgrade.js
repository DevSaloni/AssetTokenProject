import pkg from "hardhat";
const { ethers, upgrades } = pkg;

const PROXY_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

async function main() {
  const AssetTokenV2 = await ethers.getContractFactory("AssetTokenV2");

  const upgraded = await upgrades.upgradeProxy(
    PROXY_ADDRESS,
    AssetTokenV2
  );

  await upgraded.waitForDeployment();
  console.log("Upgrade successful");

  await upgraded.initializeV2();
  console.log("V2 initialized");
}

main();
