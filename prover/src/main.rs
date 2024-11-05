mod input;

use ark_circom::zkp::{
    init_bn254_circom_from_bytes, init_bn254_params_from_bytes, proof_to_abi_bytes,
    prove_bn254, verify_bn254
};
use input::{decode_prove_inputs, decode_prove_publics};

#[cfg(not(feature = "sha25665"))]
const WASM_BYTES: &[u8] = include_bytes!("../../../materials/sha256.wasm");
#[cfg(not(feature = "sha25665"))]
const R1CS_BYTES: &[u8] = include_bytes!("../../../materials/sha256.r1cs");
#[cfg(not(feature = "sha25665"))]
const ZKEY_BYTES: &[u8] = include_bytes!("../../../materials/sha256.zkey");

#[cfg(feature = "sha25665")]
const WASM_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.wasm");
#[cfg(feature = "sha25665")]
const R1CS_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.r1cs");
#[cfg(feature = "sha25665")]
const ZKEY_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.zkey");

/// INPUT=http://localhost:9098/tasks/1 cargo run --release
#[tokio::main]
async fn main() {
    let input_path = std::env::var("INPUT").expect("env INPUT missing");
    let bytes = reqwest::get(&input_path)
        .await
        .unwrap()
        .bytes()
        .await
        .unwrap();

    // parse inputs and publics
    let mut input_len_bytes = [0u8; 4];
    input_len_bytes.copy_from_slice(&bytes[0..4]);
    let input_len = u32::from_be_bytes(input_len_bytes) as usize;
    let input_bytes = &bytes[4..input_len + 4];
    let publics_bytes = &bytes[input_len + 4..];

    let inputs = decode_prove_inputs(input_bytes).expect("Unable to decode inputs");
    let publics = decode_prove_publics(publics_bytes).expect("Unable to decode publics");

    let params = init_bn254_params_from_bytes(ZKEY_BYTES, false).unwrap();

    let circom = init_bn254_circom_from_bytes(WASM_BYTES, R1CS_BYTES).unwrap();
    let (_pi, proof) = prove_bn254(&params, circom, inputs).unwrap();

    assert!(verify_bn254(&params.vk, &publics, &proof).unwrap());

    let bytes = proof_to_abi_bytes(&proof).unwrap();
    let client = reqwest::Client::new();
    client.post(&input_path).body(bytes).send().await.unwrap();
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::input::decode_prove_inputs_65;
    use std::time::Instant;

    const WASM65_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.wasm");
    const R1CS65_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.r1cs");
    const ZKEY65_BYTES: &[u8] = include_bytes!("../../../materials/sha256_65.zkey");

    #[tokio::test]
    async fn test_hash() {
        // inputs & publics
        let i_bytes = hex::decode("3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532").unwrap();
        let p_bytes = hex::decode("67b4edc746045b464a7953820100a60625e3e880dfdb2676a528abc4f475ed78").unwrap();
        let p65_bytes = hex::decode("be301418065404790d2453313b6679a2b3a3901598fbcdcc9813754a4e00e485").unwrap();

        let inputs = decode_prove_inputs(&i_bytes).expect("Unable to decode inputs");
        let inputs65 = decode_prove_inputs_65(&i_bytes).expect("Unable to decode inputs");
        let publics = decode_prove_publics(&p_bytes).expect("Unable to decode publics");
        let publics65 = decode_prove_publics(&p65_bytes).expect("Unable to decode publics");

        let now = Instant::now();

        let params = init_bn254_params_from_bytes(ZKEY_BYTES, false).unwrap();
        let circom = init_bn254_circom_from_bytes(WASM_BYTES, R1CS_BYTES).unwrap();
        let (_pi, proof) = prove_bn254(&params, circom, inputs).unwrap();
        assert!(verify_bn254(&params.vk, &publics, &proof).unwrap());

        let bytes = proof_to_abi_bytes(&proof).unwrap();
        println!("proof: 0x{}", hex::encode(&bytes));

        println!("time: {} s", now.elapsed().as_millis() as f32 / 1000f32);

        let now = Instant::now();

        let params = init_bn254_params_from_bytes(ZKEY65_BYTES, false).unwrap();
        let circom = init_bn254_circom_from_bytes(WASM65_BYTES, R1CS65_BYTES).unwrap();
        let (_pi, proof) = prove_bn254(&params, circom, inputs65).unwrap();
        assert!(verify_bn254(&params.vk, &publics65, &proof).unwrap());

        let bytes = proof_to_abi_bytes(&proof).unwrap();
        println!("proof: 0x{}", hex::encode(&bytes));

        println!("time: {} s", now.elapsed().as_millis() as f32 / 1000f32);
    }
}
