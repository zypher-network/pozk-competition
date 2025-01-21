// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades, network } = require("hardhat");

// Testnet
const WALLET = "0x5ef51c9f449db7be2f0c636c6c137e65b8b96b9b";
// const AA_WALLET = "0x614421073bda3b8f63a1cbe920f0277e3951f4af";
// const SHA256_VERIFIER = "0x432D35F3717f195070C450F471311A221EF275Cd";
// const SHA25665_VERIFIER = "0xf227AB39cAB4D4fBfb70390a46831D060C271Dd5";
// const ZKVM_VERIFIER = "0x5e7ADcFE07BDAE740b0911eeb3849C795137B256";
// const ZKVM = "0x01aB8dB3B66900568C4420773C4517fD8bD6B1E3";

// Base Sepolia
// const AA_WALLET = "0x614421073bda3b8f63a1cbe920f0277e3951f4af";
const SHA256_VERIFIER = "0xA7B1Abf5B41D42C293917Cf8d8bDdf760b326d17";
const SHA25665_VERIFIER = "0xf1A2812Fc68Ab4A8a7d08dea48DD941Db5174B6d";
const ZKVM_VERIFIER = "0x74aB6bBB479Af79eAc347cA55A55afCd7438D318";
const ZKVM = "0x8ab84F7C3b807e1fa4983972b97c191e51abcA84";

// Mainnet

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
  await deploy();
  // await allowlist(WALLET);
  // await allowlist(AA_WALLET);
  // await upgrade12();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
