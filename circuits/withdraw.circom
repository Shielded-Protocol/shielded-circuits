pragma circom 2.1.6;

include "./merkle_proof.circom";
include "./nullifier_hash.circom";
include "./lib/commitment.circom";

/// Withdrawal proof circuit — the main circuit for the Shielded Protocol.
///
/// Proves that the prover:
/// 1. Knows a secret that corresponds to a commitment in the Merkle tree
/// 2. The nullifier is correctly derived from the secret
/// 3. The commitment is in the tree at the given Merkle path
///
/// Public inputs:  root, nullifierHash, recipient, amount
/// Private inputs: secret, nullifierSecret, pathElements[20], pathIndices[20]

template Withdraw(levels) {
    // Public inputs
    signal input root;
    signal input nullifierHash;
    signal input recipient;   // Not used in constraints, but bound to proof
    signal input amount;       // Not used in constraints, but bound to proof

    // Private inputs
    signal input secret;
    signal input nullifierSecret;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    // Step 1: Compute the commitment from private inputs
    component commitmentHasher = CommitmentHasher();
    commitmentHasher.secret <== secret;
    commitmentHasher.nullifierSecret <== nullifierSecret;
    commitmentHasher.amount <== amount;

    // Step 2: Compute the nullifier hash and verify it matches the public input
    component nullifierHasher = NullifierHash();
    nullifierHasher.nullifierSecret <== nullifierSecret;
    nullifierHash === nullifierHasher.out;

    // Step 3: Verify the commitment is in the Merkle tree
    component merkleProof = MerkleProof(levels);
    merkleProof.leaf <== commitmentHasher.out;
    for (var i = 0; i < levels; i++) {
        merkleProof.pathElements[i] <== pathElements[i];
        merkleProof.pathIndices[i] <== pathIndices[i];
    }

    // Verify the computed root matches the public input
    root === merkleProof.root;

    // Bind recipient to the proof (prevents front-running)
    // Square to create a constraint without restricting the value
    signal recipientSquare;
    recipientSquare <== recipient * recipient;
}

component main {public [root, nullifierHash, recipient, amount]} = Withdraw(20);
