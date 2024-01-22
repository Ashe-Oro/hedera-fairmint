const { expect } = require('chai')
const { ethers } = require('hardhat')
const Constants = require('../utils/evmConstants')



async function main() {
    signers = await ethers.getSigners()

    const fairmintTokenContractFactory = await ethers.getContractFactory(
      "FairmintTokenContract"
    )
    const fairmintToken = await fairmintTokenContractFactory.deploy(
      Constants.GAS_LIMIT_1_000_000
    )

    const fairmintTokenReceipt = await fairmintToken.deployTransaction.wait()

    fairmintContract =  await ethers.getContractAt(
      "FairmintTokenContract",
      fairmintTokenReceipt.contractAddress
    )

    await fairmintContract.createFairmintTokenPublic();
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
