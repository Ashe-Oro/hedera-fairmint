/*-
 *
 * Hedera Smart Contracts
 *
 * Copyright (C) 2023 Hedera Hashgraph, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

const { expect } = require('chai')
const { ethers } = require('hardhat')
const Constants = require('../utils/evmConstants')
const {
  TokenCreateTransaction,
  TransactionId,
  PublicKey,
  TokenSupplyType,
  AccountId,
  Hbar,
} = require('@hashgraph/sdk')

describe('FairmintTokenContract Test Suite', function () {
  let fairmintContract
  
  let tokenTransferContract
  let tokenManagmentContract
  let tokenQueryContract
  let erc20Contract
  let tokenAddress
  let nftTokenAddress

  before(async function () {
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
  })

  // it('should be able to create token', async function () {
  //   const hbarAmount = Hbar.fromTinybars(12300000000).toBigNumber().toNumber();
  //   const fairmintConfiguration = {
  //       startTimestamp: Math.round((new Date().getTime() - 3600000) / 1000),
  //       endTimestamp: Math.round((new Date().getTime() + 3600000) / 1000),
  //       amountPerMint: 100
  //   }
  //   await fairmintContract.createFairmintTokenPublic(fairmintConfiguration, {
  //     gasLimit: 1000000,
  //     value: ethers.utils.parseEther(String(hbarAmount))
  //   });
  // })

  it('should be able to mint', async function () {
    const hbarAmount = Hbar.fromTinybars(12300000000).toBigNumber().toNumber();
    const tokenAddress = "0x00000000000000000000000000000000006753f3";
    const fairmintContract = await ethers.getContractAt(
      "FairmintTokenContract",
      "0xf949c50e8f44197feb7521265e92a041c1cb3fe1"
    )

    await fairmintContract.fairmintPublic(tokenAddress, 1000, {
      gasLimit: 1000000
    });
  })

})

