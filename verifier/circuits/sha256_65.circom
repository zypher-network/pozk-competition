pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";

// for a input of 32 * 65 bytes:
component main = Sha256(16640);
