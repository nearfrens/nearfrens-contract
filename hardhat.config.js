require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",

  networks: {
    goerli: {
      url: process.env.ALCHEMY_GOERLI,
      accounts: [process.env.PRIVATE_KEY],
      gas: "auto",
    }
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  },
};
