pragma circom 2.0.0;

include "./lib/keccak.circom";

// for a input & output of 32 bytes:
component main = Keccak(32*8, 32*8);
