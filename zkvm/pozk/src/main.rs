use sha2::{Digest as _, Sha256};
use sha3::Keccak256;
use serde_json::Value;
use chrono::Utc;

const COMPETITION_ELF_SP1: &[u8] = include_bytes!("../competition_elf_sp1");
const COMPETITION_ELF_RISC0: &[u8] = include_bytes!("../competition_elf_risc0");

/// INPUT=xx ZKVM=xx OVERTIME=xx cargo run --release
#[tokio::main]
async fn main() {
    let zkvm = "risc0"; // sp1
    let competition = COMPETITION_ELF_RISC0;

    let input_path = std::env::var("INPUT").expect("env INPUT missing");
    let zkvm_path = std::env::var("ZKVM").expect("env ZKVM missing");
    let overtime: i64 = std::env::var("OVERTIME").expect("env OVERTIME missing").parse().unwrap_or(0);
    // let input = [0u8; 32];
    // let zkvm_path = "http://54.187.128.172:9099";
    // let overtime = Utc::now().timestamp() + 600;

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

    let input = bytes[4..input_len + 4].to_vec();
    let publics = bytes[input_len + 4..].to_vec();

    // pre-check publics  // FIXME use risc-v runtime
    let mut hasher1 = Sha256::new();
    hasher1.update(&input);
    let result1 = hasher1.finalize().to_vec();

    let mut hasher2 = Keccak256::new();
    hasher2.update(&result1);
    let last = hasher2.finalize().to_vec();

    // generate risc0 groth16 digest
    let mut encode_hash = vec![32, 0, 0, 0]; // fixed 32 size
    for i in last.iter() {
        encode_hash.extend((*i as u32).to_le_bytes().to_vec());
    }
    let mut hasher3 = Sha256::new();
    hasher3.update(&encode_hash);
    let checked_publics = hasher3.finalize().to_vec();
    assert_eq!(checked_publics, publics);

    let elf_len = competition.len() as u32;
    let mut data = elf_len.to_be_bytes().to_vec();
    data.extend(competition);
    data.extend(input);

    // start zkp
    let now = std::time::Instant::now();
    let client = reqwest::Client::new();
    let res = client
        .post(format!("{zkvm_path}/prove/{zkvm}"))
        .body(data)
        .send()
        .await
        .unwrap()
        .json::<Value>()
        .await
        .unwrap();
    let track = res["track"].as_str().unwrap();
    println!("Track: {}", track);

    let mut proof = vec![];
    loop {
        tokio::time::sleep(std::time::Duration::from_secs(10)).await;
        let ress = client
            .get(format!("{zkvm_path}/prove/{track}"))
            .send()
            .await
            .unwrap()
            .json::<Value>()
            .await
            .unwrap();
        if let Some(p) = ress.get("proof") {
            proof = hex::decode(p.as_str().unwrap()).unwrap();
            break;
        }

        if let Some(e) = ress.get("error") {
            println!("Error: {}", e);
            break;
        }

        println!("{}", ress);

        let now = Utc::now().timestamp();
        if now > overtime {
            // FIXME more handle about failure
            return;
        }
    }

    println!("proof: {}, time: {}", hex::encode(&proof), now.elapsed().as_secs());

    let client = reqwest::Client::new();
    client.post(&input_path).body(proof).send().await.unwrap();
}
