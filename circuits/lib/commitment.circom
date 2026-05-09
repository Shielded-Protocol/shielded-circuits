pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/poseidon.circom";

/// Commitment hasher: commitment = Poseidon(secret, nullifierSecret, amount)
///
/// This is the core commitment scheme. A commitment binds the user to:
/// - Their secret (knowledge proof)
/// - Their nullifier secret (for spending)
/// - The amount deposited
///
/// The commitment is stored on-chain in the Merkle tree.
/// The preimage (secret, nullifierSecret, amount) remains private.

template CommitmentHasher() {
    signal input secret;
    signal input nullifierSecret;
    signal input amount;

    signal output out;

    component hasher = Poseidon(3);
    hasher.inputs[0] <== secret;
    hasher.inputs[1] <== nullifierSecret;
    hasher.inputs[2] <== amount;

    out <== hasher.out;
}
