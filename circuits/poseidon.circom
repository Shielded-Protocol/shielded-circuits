pragma circom 2.1.6;

/// Poseidon hash wrapper.
///
/// Re-exports the Poseidon hash from circomlib for use across circuits.
/// Poseidon is a ZK-friendly hash function designed for efficient
/// arithmetic circuit implementation over prime fields.
///
/// Usage:
///   include "./poseidon.circom";
///   component hasher = PoseidonHash(2);
///   hasher.inputs[0] <== a;
///   hasher.inputs[1] <== b;
///   out <== hasher.out;

include "../node_modules/circomlib/circuits/poseidon.circom";

template PoseidonHash(nInputs) {
    signal input inputs[nInputs];
    signal output out;

    component hasher = Poseidon(nInputs);
    for (var i = 0; i < nInputs; i++) {
        hasher.inputs[i] <== inputs[i];
    }
    out <== hasher.out;
}
