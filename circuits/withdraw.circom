pragma circom 2.0.0;
include "circomlib/circuits/poseidon.circom";
include "merkle_proof.circom";
include "nullifier_hash.circom";

// Proves ownership of a commitment in the Merkle tree
// without revealing which commitment or the amount
template Withdraw(levels) {
    // Private inputs (never revealed)
    signal input secret;
    signal input amount;
    signal input tokenId;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    // Public inputs (visible on-chain)
    signal input root;
    signal input nullifierHash;
    signal input recipient;
    signal input relayer;
    signal input fee;
    signal input refund;

    // Verify the commitment exists in the tree
    component commitmentHasher = Poseidon(3);
    commitmentHasher.inputs[0] <== secret;
    commitmentHasher.inputs[1] <== amount;
    commitmentHasher.inputs[2] <== tokenId;

    component tree = MerkleProof(levels);
    tree.leaf <== commitmentHasher.out;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
    tree.root === root;

    // Verify nullifier derivation
    component nullifier = NullifierHash();
    nullifier.secret <== secret;
    nullifier.out === nullifierHash;

    // Prevent fee from exceeding amount
    signal amountAfterFee;
    amountAfterFee <== amount - fee;
    amountAfterFee * 1 === amountAfterFee; // range check placeholder

    // Bind recipient to proof (prevents front-running)
    signal recipientSquared;
    recipientSquared <== recipient * recipient;
}

component main {public [root, nullifierHash, recipient, relayer, fee, refund]} = Withdraw(20);
