pragma circom 2.0.0;
include "circomlib/circuits/poseidon.circom";

/// Nullifier hash derivation circuit.
template NullifierHash() {
    signal input secret;
    signal output out;

    component hasher = Poseidon(1);
    hasher.inputs[0] <== secret;

    out <== hasher.out;
}
