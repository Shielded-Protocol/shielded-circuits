# shielded-circuits

[![CI](https://github.com/Shielded-Protocol/shielded-circuits/actions/workflows/ci.yml/badge.svg)](https://github.com/Shielded-Protocol/shielded-circuits/actions/workflows/ci.yml)
[![Stellar Wave](https://img.shields.io/badge/Stellar-Wave-blue)](https://drips.network/wave/stellar)
[![Issues](https://img.shields.io/github/issues/Shielded-Protocol/shielded-circuits)](https://github.com/Shielded-Protocol/shielded-circuits/issues)

The zero-knowledge circuits for [Shielded Protocol](https://github.com/Shielded-Protocol). Written in **Circom 2**, compiled to Groth16 proofs on the BN254 elliptic curve.

---

## What are ZK circuits?

A zero-knowledge circuit is a program that can prove a statement is true **without revealing the inputs** used to prove it.

In Shielded Protocol, the key statement is:

> *"I know a secret that corresponds to a commitment already in the Merkle tree, and I have not spent it before."*

Proving this on-chain lets the smart contract release funds to the recipient — without ever learning **who** deposited them or **which** commitment is being spent.

---

## Proving system

| Property | Value |
|---|---|
| Proving system | Groth16 |
| Elliptic curve | BN254 (alt_bn128) |
| Hash function | Poseidon (ZK-friendly, ~200× cheaper than SHA-256 in constraints) |
| Merkle tree depth | 20 (supports 2²⁰ = 1,048,576 notes) |
| Proof size | 3 elliptic curve points (~256 bytes) — constant regardless of tree size |
| On-chain verification | O(1) via Stellar BN254 host functions |

---

## Circuits

### `withdraw.circom` — the main circuit

Used when a user wants to withdraw funds. Proves all three things simultaneously:

1. **Membership:** The note's commitment exists in the Merkle tree (via a Merkle inclusion proof)
2. **Ownership:** The prover knows the secret that created the commitment
3. **Non-reuse:** The nullifier has not been used before (checked on-chain against a nullifier set)

**Private inputs** (never revealed):

| Input | Description |
|---|---|
| `secret` | 31-byte random scalar generated at deposit time |
| `amount` | Token amount in the note |
| `tokenId` | Identifier for the token type |
| `pathElements[20]` | Sibling hashes along the Merkle path |
| `pathIndices[20]` | Left/right flags for each Merkle level |

**Public inputs** (visible on-chain):

| Input | Description |
|---|---|
| `root` | Merkle tree root at proof time |
| `nullifierHash` | Deterministic hash of the secret — marks the note as spent |
| `recipient` | Address that receives the withdrawn funds |
| `relayer` | Optional relayer address (for gas-less withdrawals) |
| `fee` | Optional relayer fee |

---

### `deposit.circom` — commitment generation

Used at deposit time to verify the commitment is correctly formed.

| Inputs | Description |
|---|---|
| `secret` (private) | The randomly generated note secret |
| `amount` (private) | Amount being deposited |
| `tokenId` (private) | Token identifier |

Outputs `commitment = Poseidon(secret, amount, tokenId)`, which is inserted into the on-chain Merkle tree.

---

### `merkle_proof.circom` — Merkle inclusion

A standalone Merkle inclusion circuit reused by `withdraw.circom`. Proves that a leaf (commitment) is included in a tree with a given root, given the path of sibling hashes.

Depth: 20 levels → 20 Poseidon2 hashes → ~24,000 constraints.

---

### `nullifier_hash.circom` — nullifier derivation

Derives the nullifier from the secret: `nullifier = Poseidon(secret, 1)`.

This is deterministic (same secret always gives the same nullifier) but **not reversible** — you cannot recover the secret from the nullifier. This lets the on-chain contract check for double-spending without being able to link the nullifier back to a commitment.

---

## Constraint counts

| Circuit | Constraints | Bottleneck |
|---|---|---|
| `withdraw` (depth 20) | ~26,000 | 20 × Poseidon2 for Merkle path |
| `merkle_proof` (depth 20) | ~24,000 | Same — Merkle path hashing |
| `deposit` | ~200 | Single Poseidon3 |
| `nullifier_hash` | ~100 | Single Poseidon2 |

Lower constraints = faster proof generation. See the [constraint reduction issue](https://github.com/Shielded-Protocol/shielded-circuits/issues) for planned optimizations.

---

## How the withdraw proof works (end to end)

```
User's browser (private)                    On-chain (public)
──────────────────────────────────────────────────────────────
secret, amount, tokenId
        │
        ▼
commitment = Poseidon(secret, amount, tokenId)
        │
        ▼
Merkle path (fetched from chain)
        │
        ▼
[ witness generation ]
        │
        ▼
[ Groth16 proof ] ─────────────────────────► proof (256 bytes)
                                             nullifierHash
                                             root
                                             recipient
                                                    │
                                                    ▼
                                         groth16-verifier contract
                                                    │
                                         ✓ proof valid
                                         ✓ root matches current tree
                                         ✓ nullifier not yet spent
                                                    │
                                                    ▼
                                         → release funds to recipient
```

---

## Quickstart

**Prerequisites:** Node.js 20+, circom 2.x, snarkjs

```bash
# Install global tools
npm install -g circom snarkjs

# Clone and install
git clone https://github.com/Shielded-Protocol/shielded-circuits
cd shielded-circuits
npm install

# Compile all circuits to R1CS + WASM
npm run compile

# Run tests (generates proofs and verifies them)
npm test
```

---

## Directory structure

```
circuits/
├── withdraw.circom       ← Main withdrawal proof (~26K constraints)
├── deposit.circom        ← Commitment generation (~200 constraints)
├── merkle_proof.circom   ← Merkle inclusion helper (~24K constraints)
├── nullifier_hash.circom ← Nullifier derivation (~100 constraints)
├── poseidon.circom       ← Poseidon hash primitive
└── lib/                  ← Shared circuit utilities
```

---

## Trusted setup

Groth16 requires a one-time **trusted setup** (also called a "powers of tau" ceremony). The setup produces two keys:

- **Proving key** — used by the prover (browser) to generate proofs
- **Verifying key** — used by the on-chain verifier to check proofs

Shielded Protocol uses the [Hermez Powers of Tau ceremony](https://github.com/iden3/snarkjs#7-prepare-phase-2) for the universal phase 1, and performs circuit-specific phase 2 setup.

> If you are doing a fresh deployment, run `npm run setup` to perform the phase 2 ceremony. For production, use a multi-party computation (MPC) ceremony.

---

## Security notes

- Keeping your `secret` private is the only security requirement. The circuit itself does not need to be trusted.
- The verifying key embedded in the on-chain contract must match the proving key used to generate proofs.
- Poseidon parameters used here: `t=3` for commitments, `t=2` for nullifiers and Merkle hashing.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

Browse [Wave-ready issues →](https://github.com/Shielded-Protocol/shielded-circuits/issues?q=label%3Astatus%3Awave-ready+state%3Aopen)

Good first issues are labeled `layer:circuits` and `difficulty:easy`.

---

## Related repos

| Repo | Description |
|---|---|
| [shielded-contracts](https://github.com/Shielded-Protocol/shielded-contracts) | On-chain Groth16 verifier that consumes these proofs |
| [shielded-sdk](https://github.com/Shielded-Protocol/shielded-sdk) | TypeScript SDK that calls these circuits from the browser |
| [shielded-app](https://github.com/Shielded-Protocol/shielded-app) | Frontend UI |

---

## License

MIT
