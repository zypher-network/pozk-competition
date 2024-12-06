// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades, network } = require("hardhat");

// Testnet (opbnbtestnet)
const SHA256_VERIFIER = "0x1248e1031c4d81a678c63811d7bf714b1a18220b";
const SHA25665_VERIFIER = "0x9b0b9bfcd3e1e3715bead7639d93b9c87a74b32a";
const ZKVM_VERIFIER = "0x765CDA9C22cC91F06292280207D18507905D5122";
const ZKVM = "0x8dfff0d3ad663fde21fdddf11a7e981bdd311911";

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
  await deployContractWithProxy("Sha256Verifier", []);
  await deployContractWithProxy("Sha25665Verifier", []);

  const address = await deployContract("ZKVMVerifier");
  await deployContractWithProxy("ZKVM", [address]);
}

async function allowlist(account) {
  const C1 = await ethers.getContractFactory("Sha256Verifier");
  const c1 = await C1.attach(SHA256_VERIFIER);
  await c1.allow(account, true);
  console.log("Set Competiton 1 Allow OK");

  const C2 = await ethers.getContractFactory("Sha25665Verifier");
  const c2 = await C2.attach(SHA25665_VERIFIER);
  await c2.allow(account, true);
  console.log("Set Competiton 2 Allow OK");

  const C3 = await ethers.getContractFactory("ZKVMVerifier");
  const c3 = await C3.attach(ZKVM_VERIFIER);
  await c3.allow(account, true);
  console.log("Set Competiton 3 Allow OK");
}

async function upgrade12() {
  console.log("Sha256Verifier upgrading...");
  const C1 = await ethers.getContractFactory("Sha256Verifier");
  const address1 = await C1.attach(SHA256_VERIFIER);
  await upgrades.upgradeProxy(address1, C1);
  console.log("Sha256Verifier upgraded");

  console.log("Sha25665Verifier upgrading...");
  const C2 = await ethers.getContractFactory("Sha25665Verifier");
  const address2 = await C2.attach(SHA25665_VERIFIER);
  await upgrades.upgradeProxy(address2, C2);
  console.log("Sha25665Verifier upgraded");
}

async function main() {
  // await deploy();
  // await allowlist("0xee20a1b9f86ed8263a4a4f6a6d9cbfdf2f88424d");
  await upgrade12();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
