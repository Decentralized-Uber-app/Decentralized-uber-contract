import { ethers } from "hardhat";

async function main() {
  //DEPLOYING THE UBER CONTRACT
  const Ubercontract = await ethers.getContractFactory("Uber");
  const uber = await Ubercontract.deploy("0x99E11732C5488Ad4b85ed93E46d23b46e736E6f9");

  await uber.deployed();

  console.log(`Uber contract is deployed to ${uber.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
