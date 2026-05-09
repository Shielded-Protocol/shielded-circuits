pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";

/// Merkle inclusion proof circuit.
///
/// Verifies that a leaf is included in a Merkle tree with a given root.
/// Uses Poseidon hash for internal nodes.
///
/// The path is represented as:
/// - pathElements: sibling hashes at each level
/// - pathIndices:  0 if the node is on the left, 1 if on the right

template MerkleProof(levels) {
    signal input leaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    signal output root;

    // Intermediate hashes at each level
    component hashers[levels];
    signal levelHashes[levels + 1];
    levelHashes[0] <== leaf;

    for (var i = 0; i < levels; i++) {
        hashers[i] = Poseidon(2);

        // pathIndices[i] must be 0 or 1
        pathIndices[i] * (1 - pathIndices[i]) === 0;

        // If pathIndices[i] == 0: hash(current, sibling)
        // If pathIndices[i] == 1: hash(sibling, current)
        hashers[i].inputs[0] <== levelHashes[i] + (pathElements[i] - levelHashes[i]) * pathIndices[i];
        hashers[i].inputs[1] <== pathElements[i] + (levelHashes[i] - pathElements[i]) * pathIndices[i];

        levelHashes[i + 1] <== hashers[i].out;
    }

    root <== levelHashes[levels];
}
