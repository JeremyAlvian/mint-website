
const hre = require("hardhat");

async function main() {

  const FuzzNFT = await hre.ethers.getContractFactory("FuzzNFT");
  const fuzzNFT = await FuzzNFT.deploy();

  await fuzzNFT.deployed();

  console.log("RoboPunksNFT deployed to:", fuzzNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
