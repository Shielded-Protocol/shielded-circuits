pragma circom 2.0.0;
include "circomlib/circuits/poseidon.circom";

/// Deposit commitment circuit.
/// commitment = Poseidon(secret, amount, tokenId)
template Deposit() {
    // Private inputs
    signal input secret;
    signal input amount;
    signal input tokenId;

    // Public output
    signal output commitment;

    component hasher = Poseidon(3);
    hasher.inputs[0] <== secret;
    hasher.inputs[1] <== amount;
    hasher.inputs[2] <== tokenId;

    commitment <== hasher.out;
}

component main = Deposit();
