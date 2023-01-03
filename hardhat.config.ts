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
      url: process.env.MUMBAI,
      // @ts-ignore
      accounts: [process.env.PRIVATE_KEY_1]
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: "1PUJPJGSC1I7S7CPZVBQE8N5BB1A3ZK5RN"
    }
  }
};

export default config;