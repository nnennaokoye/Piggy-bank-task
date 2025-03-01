import { ethers } from "hardhat";

const TOKENS = {
  USDC: "0xdAC17F958D2ee523a2206206994597C13D831ec7", 
  USDT: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", 
  DAI: "0x6B175474E89094C44Da98b954EedeAC495271d0F"  
};



async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const purpose = process.argv[2] || "Default Savings Purpose"; // Default  if not provided
  const duration = parseInt(process.argv[3]) || (30 * 24 * 60 * 60); // Default to 30 days if not provided

  const PiggyBankFactory = await ethers.getContractFactory("PiggyFactory");
  const factory = await PiggyBankFactory.deploy(deployer.address);
  await factory.waitForDeployment();

  console.log("PiggyBankFactory deployed to:", await factory.getAddress());
  
   const salt = ethers.encodeBytes32String("uniqueSalt");
  
  // const tx = await factory.createPiggyBank(purpose, duration, salt);
  // await tx.wait();

  const piggyBanks = await factory.getAllPiggyBanks();
  console.log("Sample PiggyBank deployed to:", piggyBanks);

  console.log("\nSupported tokens:");
  console.log("USDC:", TOKENS.USDC);
  console.log("USDT:", TOKENS.USDT);
  console.log("DAI:", TOKENS.DAI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});