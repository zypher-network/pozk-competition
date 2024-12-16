//! A simple program that takes a number `n` as input, and writes the `n-1`th and `n`th fibonacci
//! number as an output.

// These two lines are necessary for the program to properly compile.
//
// Under the hood, we wrap your main function with some extra code so that it behaves properly
// inside the zkVM.
#![no_main]
sp1_zkvm::entrypoint!(main);

use sha2::{Sha256, Digest};
use sha3::Keccak256;

pub fn main() {
    // Read an input to the program.
    let input = sp1_zkvm::io::read::<[u8; 32]>();

    let mut hasher = Sha256::new();
    hasher.update(&input);
    let result = hasher.finalize().to_vec();

    let mut hasher2 = Keccak256::new();
    hasher2.update(&result);
    let last = hasher2.finalize().to_vec();

    // Commit to the public values of the program.
    sp1_zkvm::io::commit_slice(&last);
}
