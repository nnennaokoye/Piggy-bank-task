import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import * as dotenv from "dotenv";

dotenv.config();

const BASE_SEPOLIA_URL = process.env.BASE_SEPOLIA_URL || "https://rpc.sepolia-api.lisk.com"; // Default value
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const BASE_API_KEY = process.env.BASE_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: process.env.ALCHEMY_SEPOLIA_API_KEY_URL,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY || ''],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  sourcify: {
    enabled: false,
  },
 
};

export default config;