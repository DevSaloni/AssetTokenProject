import "@nomicfoundation/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";

/** @type {import("hardhat/config.js").HardhatUserConfig} */
export default {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
  },
};
