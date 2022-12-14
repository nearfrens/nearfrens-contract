require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",

  networks: {
    goerli: {
      url: process.env.ALCHEMY_GOERLI,
      accounts: [process.env.PRIVATE_KEY],
      gas: "auto",
    },
    mumbai: {
      url: process.env.ALCHEMY_MUMBAI,
      accounts: [process.env.ALICE],
      gas: "auto",
    },
    polygon: {
      url: process.env.ALCHEMY_POLYGON,
      accounts: [process.env.BOB],
      gas: "auto",
    }
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  },
};
