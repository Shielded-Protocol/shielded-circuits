# shielded-circuits

> Circom ZK circuits for Shielded Protocol.

Part of [Shielded Protocol](https://github.com/Shielded-Protocol) —
private, compliant DeFi on Stellar.

[![CI](https://github.com/Shielded-Protocol/shielded-circuits/actions/workflows/ci.yml/badge.svg)](https://github.com/Shielded-Protocol/shielded-circuits/actions/workflows/ci.yml)
[![Stellar Wave](https://img.shields.io/badge/Stellar-Wave-blue)](https://drips.network/wave/stellar)
[![Issues](https://img.shields.io/github/issues/Shielded-Protocol/shielded-circuits)](https://github.com/Shielded-Protocol/shielded-circuits/issues)

---

## Circuits

| Circuit | Inputs (private) | Inputs (public) | Purpose |
|---|---|---|---|
| `withdraw.circom` | secret, amount, tokenId, pathElements, pathIndices | root, nullifierHash, recipient, relayer, fee | Main withdrawal proof |
| `deposit.circom` | secret, amount, tokenId | — | Commitment generation |
| `merkle_proof.circom` | leaf, pathElements, pathIndices | root | Merkle inclusion proof |
| `nullifier_hash.circom` | secret | — | Nullifier derivation |

**Proving system:** Groth16 · **Curve:** BN254 · **Hash:** Poseidon · **Depth:** 20

---

## How the withdraw proof works

```
Private: secret, amount, tokenId, Merkle path
                    │
                    ▼
         commitment = Poseidon(secret, amount, tokenId)
                    │
                    ▼
    Merkle proof: commitment ∈ tree with known root ──► Public: root
                    │
         nullifier = Poseidon(secret, 1) ──────────────► Public: nullifierHash
                    │
    recipient bound into proof ────────────────────────► Public: recipient
```

The proof reveals nothing about the secret, amount, or which commitment is spent.

Quickstart
# Prerequisites: Node 20+, circom 2.x, snarkjs

npm install -g circom snarkjs
npm install

# Compile circuits (generates R1CS + WASM)
npm run compile

# Run tests
npm test

---

## Constraint counts (approximate)

| Circuit | Constraints | Notes |
|---|---|---|
| `withdraw` (depth 20) | ~26,000 | Dominated by Merkle path hashing |
| `deposit` | ~200 | Simple Poseidon hash |
| `merkle_proof` (depth 20) | ~24,000 | 20 × Poseidon2 |
| `nullifier_hash` | ~100 | Single Poseidon2 |

See issue [#constraint-reduction](https://github.com/Shielded-Protocol/shielded-circuits/issues)
for optimization work.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

Browse [Wave-ready issues](https://github.com/Shielded-Protocol/shielded-circuits/issues?q=label%3Astatus%3Awave-ready+state%3Aopen).

---

## License

MIT
