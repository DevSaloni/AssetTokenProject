import pkg from "hardhat";
const { ethers, upgrades } = pkg;

async function main() {
  const AssetToken = await ethers.getContractFactory("AssetToken");

  const proxy = await upgrades.deployProxy(
    AssetToken,
    ["Asset Token", "AST", 1_000_000n * 10n ** 18n],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );

  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  console.log("PROXY ADDRESS:", proxyAddress);
}

main();
