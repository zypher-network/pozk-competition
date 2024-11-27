// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades, network } = require("hardhat");
const { attachContract, sleep } = require("./address_utils.js");
const { writeFile } = require('fs');

// Testnet (opbnbtestnet)
const TASK_ADDRESS = "0x66e9CE70bb3431958e0CE352d1B5D85772E57E06";
// Sha256Verifier address: 0x1248e1031c4d81a678c63811d7bf714b1a18220b
// Sha25665Verifier address: 0x9b0b9bfcd3e1e3715bead7639d93b9c87a74b32a
// ZKVMVerifier address: 0x765CDA9C22cC91F06292280207D18507905D5122
// ZKVM address: 0x8dfff0d3ad663fde21fdddf11a7e981bdd311911

async function deployContractWithProxy(name, params=[]) {
  const Factory = await ethers.getContractFactory(name);
  //  use upgradeable deploy, then contracts can be upgraded success, otherwise will get error about ERC 1967 proxy
  const contract = await upgrades.deployProxy(Factory, params);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log(`${name} address: ${address}`);

  return address;
}

async function deployContract(name, params=[]) {
  const Factory = await ethers.getContractFactory(name);
  const contract = await Factory.deploy(...params);
  const address = await contract.getAddress();
  console.log(`${name} address: ${address}`);

  return address;
}

async function deploy() {
  await deployContractWithProxy("Sha256Verifier", [TASK_ADDRESS]);
  await deployContractWithProxy("Sha25665Verifier", [TASK_ADDRESS]);

  const address = await deployContract("ZKVMVerifier");
  await deployContractWithProxy("ZKVM", [TASK_ADDRESS, address]);
}

async function updateTask(name, address) {
  const C = await ethers.getContractFactory(name);
  return await C.attach(address);
  await c.setTask(TASK_ADDRESS);
}

async function main() {
  await deploy();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
