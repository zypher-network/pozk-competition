// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades, network } = require("hardhat");

const ADDR1 = "0xb216af68a82538ff12edc8ac9eec3e91eaa54e9e";
const ADDR2 = "0x614e0cccba48c2bb4da3f05704874f80e3a551d5";
const ADDR3 = "";

async function testVerify() {
  const C1 = await ethers.getContractFactory("Sha256Verifier");
  const c1 = await C1.attach(ADDR1);

  const res1 = await c1.verify(
    "0x67b4edc746045b464a7953820100a60625e3e880dfdb2676a528abc4f475ed78",
    "0x2d76fb7af508e1765a15d828097b95031342be85f10459eb8b18d5992f6bf05b269848cbc08af2c3490527219e6979ab39c2b1cf5e0b9ceeef0965df7a53c3c024d3a2674de7e2bace975c66c01ce38a49516da0929f13405c6ebe186ca9971d00671488d6e02462998c68dd3c787f6e034ad89f3f47c7cba2ab41c0d15a399d1e381f529c17a6871cf6fcc5b40d0ad5ea07f92966514b4406cd29e91bd58f60102961a6a9e3405fe59642601e0eb84f509bf1ecadc0a06bd0ac5ebc01ce40a029902de9001931bf8ab986d432afb4e98b9d72fe1728ff97b8f15263a95cffb802e01c4b85ca0cd034f92c385d1d459feb6b497a133a7efb3f36813b17a407e1"
  );
  console.log(`Verify 1: ${res1}`);

  const C2 = await ethers.getContractFactory("Sha25665Verifier");
  const c2 = await C2.attach(ADDR2);
  const res2 = await c2.verify(
    "0xbe301418065404790d2453313b6679a2b3a3901598fbcdcc9813754a4e00e485",
    "0x2e96237320310139b7f1f531b4da3cce1b21b6e6c2b8dfd719c346382b75516313396c56f1a6cd8f2c264fff5f78ee5cc0d00529a57050ec63677e3e6cdde4242f2a15ced71251b1fae8128cea39873c2956af467471fb661b8a9cb939b5f09327a459fed7deda0a1485b042eb9716b104175a495976105f7d4fde3c25b3da8425bfb535167008a6c7c6565b27c0604dcf0430c0ec543ecaef688af2ec1e954105cceb1d2aaeaf3129540a35529b2e82d0ebf1b389794d94091aa5dd26d65862017f1f5e2ee7b34ae123bcf9f8d3e9ebedc333663eecfe9d37690bfeb67da950120b2ae65a3c8aec0454c896caadcedb9db9679f27f7f5e94056d9ffd68bd81d"
  );
  console.log(`Verify 2: ${res2}`);

  const C3 = await ethers.getContractFactory("ZKVMVerifier");
  const c3 = await C3.attach(ADDR3);
  const res3 = await c3.verify(
    "0xfd46451a036048a3c20255db6d0a8af6bc6356c060a7600ed25449f18b52d668",
    "0x50bd17691221a4cdca249c64642bcfaf24879c7fcf26b7395e7b239c85a7f4f77f1f396c1bc4a7fcdf6338443af4de1daf45f7ec465c5d86f61bf08a5c92278cc37100b500503c1b4e793bf8be0b9d4aa5842ce09fadeef968b91746c6c246f403bbd04602b3a8cfff38455396e8d6dc6ce1db4883c6dbd8450497029f966ebf170b4576259f5796be1440ace5013821e612a1616e593d81fd746b52984fe7e9520d39880723c3014049cefea02a3a190d0e22d15f9a4695d26d9c973fc60adb56c998e02293422bcbde3628a90cdeef941d9f8a6712fe7fb9c7b0ce810f4cdcfcf1709f2b2534f696fe4543fe288587bb89acebfef9cd010e21254f5cc7ae2e85e77b0e"
  );
  console.log(`Verify 3: ${res3}`);
}

async function main() {
  await testVerify();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
