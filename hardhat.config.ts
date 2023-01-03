import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();


const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.9"
      }
    ]
  },
  networks: {
    mumbai: {
      url: process.env.ALCHEMY_GOERLI_API_KEY_URL,
      // @ts-ignore
      accounts: [process.env.ACCOUNT_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: "TTVCBmWUC4PuCmW3X51eCzLZd0v_F3nE"
    }
  }
};

export default config;