use risc0_zkvm::guest::env;
use sha2::{Sha256, Digest};
use sha3::Keccak256;

fn main() {
    // read the input
    let input: [u8; 32] = env::read();

    let mut hasher = Sha256::new();
    hasher.update(&input);
    let result = hasher.finalize().to_vec();

    let mut hasher2 = Keccak256::new();
    hasher2.update(&result);
    let last = hasher2.finalize().to_vec();

    // write public output to the journal
    env::commit(&last);
}
