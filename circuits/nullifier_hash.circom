pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";

/// Nullifier hash derivation circuit.
///
/// The nullifier is derived deterministically from the nullifier secret:
///   nullifierHash = Poseidon(nullifierSecret)
///
/// This ensures each commitment can only produce one unique nullifier,
/// preventing double-spend without revealing which commitment was spent.

template NullifierHash() {
    signal input nullifierSecret;
    signal output out;

    component hasher = Poseidon(1);
    hasher.inputs[0] <== nullifierSecret;

    out <== hasher.out;
}
