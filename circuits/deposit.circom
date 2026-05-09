pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";

/// Deposit commitment circuit.
///
/// Proves that a commitment is correctly formed as:
///   commitment = Poseidon(secret, nullifier_secret, amount)
///
/// Public inputs:  commitment
/// Private inputs: secret, nullifier_secret, amount

template Deposit() {
    // Private inputs
    signal input secret;
    signal input nullifierSecret;
    signal input amount;

    // Public output
    signal output commitment;

    // Compute commitment = Poseidon(secret, nullifierSecret, amount)
    component hasher = Poseidon(3);
    hasher.inputs[0] <== secret;
    hasher.inputs[1] <== nullifierSecret;
    hasher.inputs[2] <== amount;

    commitment <== hasher.out;
}

component main {public []} = Deposit();
