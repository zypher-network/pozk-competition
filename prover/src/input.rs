use std::collections::HashMap;

use ark_circom::zkp::Input;
use ark_bn254::Fr;
use ethabi::{decode, ParamType};
use num_bigint::BigInt;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct KeccakInput {
    pub input: String,
    pub output: String,
}

#[allow(dead_code)]
pub fn encode_prove_inputs(inputs: &KeccakInput) -> String {
    if inputs.input.starts_with("0x") {
        inputs.input.clone()
    } else {
        format!("0x{}", inputs.input)
    }
}

pub fn decode_prove_publics(bytes: &[u8]) -> Result<Vec<Fr>, anyhow::Error> {
    let mut output = vec![];
    for byte in &bytes[0..4] {
        for i in 0..8 {
            output.push(Fr::from(byte >> (7 - i) & 1));
        }
    }

    Ok(output)
}


#[cfg(not(feature = "sha25665"))]
pub fn decode_prove_inputs(bytes: &[u8]) -> Result<Input, anyhow::Error> {
    let mut input_tokens = decode(
        &[ParamType::FixedBytes(32)],
        bytes,
    )?;
    let bytes = input_tokens.pop().unwrap().into_fixed_bytes().unwrap();

    let mut input = vec![];
    for byte in bytes {
        for i in 0..8 {
            input.push(BigInt::from(byte >> (7 - i) & 1));
        }
    }

    let mut maps = HashMap::new();
    maps.insert("in".to_owned(), input);

    Ok(Input { maps })
}


#[cfg(feature = "sha25665")]
pub fn decode_prove_inputs(bytes: &[u8]) -> Result<Input, anyhow::Error> {
    decode_prove_inputs_65(bytes)
}

pub fn decode_prove_inputs_65(bytes: &[u8]) -> Result<Input, anyhow::Error> {
    let mut input_tokens = decode(
        &[ParamType::FixedBytes(32)],
        bytes,
    )?;
    let mut bytes = input_tokens.pop().unwrap().into_fixed_bytes().unwrap();

    let mut next_input = bytes.clone();
    for _ in 0..64 {
        let mut hasher = Sha256::new();
        hasher.update(&next_input);
        next_input = hasher.finalize().to_vec();
        bytes.extend(&next_input)
    }

    let mut input = vec![];
    for byte in bytes {
        for i in 0..8 {
            input.push(BigInt::from(byte >> (7 - i) & 1));
        }
    }

    let mut maps = HashMap::new();
    maps.insert("in".to_owned(), input);

    Ok(Input { maps })
}

#[cfg(test)]
mod test {
    use super::*;
    use sha2::Sha256;

    #[test]
    fn test_serialize() {
        let input_hex = "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532";
        let input_bytes = hex::decode(&input_hex).unwrap();

        let mut hasher1 = Sha256::new();
        hasher1.update(&input_bytes);
        let result1 = hasher1.finalize();

        let mut input_65 = input_bytes.clone();
        let mut next_input = input_bytes;
        for _ in 0..64 {
            let mut hasher = Sha256::new();
            hasher.update(&next_input);
            next_input = hasher.finalize().to_vec();
            input_65.extend(&next_input);
        }

        let mut hasher2 = Sha256::new();
        hasher2.update(&input_65);
        let result2 = hasher2.finalize();

        let input = format!("0x{}", input_hex);
        let output1 = format!("0x{}", hex::encode(&result1[..]));
        let output2 = format!("0x{}", hex::encode(&result2[..]));

        let input = KeccakInput { input, output: output1.clone() };

        let hex = encode_prove_inputs(&input);
        println!("inputs             {}", hex);
        println!("outputs(sha256)    {}", output1);
        println!("outputs(sha256_65) {}", output2);

        let input_hex = hex.trim_start_matches("0x");
        let output1_hex = output1.trim_start_matches("0x");
        let output2_hex = output2.trim_start_matches("0x");
        let inputs_bytes = hex::decode(input_hex).expect("Unable to decode input file");
        let publics1_bytes = hex::decode(output1_hex).expect("Unable to decode input file");
        let publics2_bytes = hex::decode(output2_hex).expect("Unable to decode input file");
        decode_prove_inputs(&inputs_bytes).expect("Unable to decode input");

        std::fs::write("./test_miner_1", format!("{}\n{}", hex, output1)).unwrap();
        std::fs::write("./test_miner_2", format!("{}\n{}", hex, output2)).unwrap();

        let mut bytes1 = (inputs_bytes.len() as u32).to_be_bytes().to_vec();
        bytes1.extend(inputs_bytes.clone());
        let mut bytes2 = bytes1.clone();
        bytes1.extend(publics1_bytes);
        bytes2.extend(publics2_bytes);
        std::fs::write("./test_inputs_1", bytes1).unwrap();
        std::fs::write("./test_inputs_2", bytes2).unwrap();
    }
}
