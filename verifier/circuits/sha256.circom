pragma circom 2.0.0;

include "./lib/sha256.circom";

// for a input of 32 bytes:
component main = Sha256(256);
