// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades, network } = require("hardhat");
const { attachContract, sleep } = require("./address_utils.js");
const { writeFile } = require('fs');

const NAME1 = "Sha256Verifier";
const NAME2 = "Sha25665Verifier";
const NAME3 = "ZKVMVerifier";

const ADDR1 = "0xb216af68a82538ff12edc8ac9eec3e91eaa54e9e";
const ADDR2 = "0x614e0cccba48c2bb4da3f05704874f80e3a551d5";
const ADDR3 = "";

// wallet: 0x5ef51c9f449db7be2f0c636c6c137e65b8b96b9b
const AA = "0x4e3111334ba387ddf000966cde24db35245fdc59";

async function upgrade(name, addr) {
  const C = await ethers.getContractFactory(name);
  const address = await C.attach(addr);
  const Factory = await ethers.getContractFactory(name);
  console.log(`${name} upgrading...`);
  await upgrades.upgradeProxy(address, Factory);
  console.log(`${name} upgraded`);
}

async function setAllow(name, addr, account) {
  const C = await ethers.getContractFactory(name);
  const c = await C.attach(addr);
  // await c.allow(account, true);
  const res = await c.allowlist(account);
  console.log(`${name} ${account} allowed: ${res}`);
}

async function main() {
  // await upgrade(NAME1, ADDR1);

  await setAllow(NAME1, ADDR1, AA);
  // await setAllow(NAME2, ADDR2, AA);
  // await setAllow(NAME3, ADDR3, AA);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
