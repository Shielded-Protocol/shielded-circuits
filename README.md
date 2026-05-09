# Shielded Circuits

Zero-knowledge circuits for the Shielded Protocol, built with [Circom 2.x](https://docs.circom.io/).

## Overview

These circuits implement the ZK proof system (Groth16 over BN254) that powers private transactions on Stellar Soroban. Users generate proofs off-chain using these circuits, which are then verified on-chain by the `groth16-verifier` contract.

## Circuits

| Circuit | Description |
|---|---|
| `deposit.circom` | Proves correct commitment formation: `commitment = Poseidon(secret, nullifier, amount)` |
| `withdraw.circom` | Main circuit — proves knowledge of secret + Merkle tree inclusion |
| `merkle_proof.circom` | Merkle inclusion proof (20 levels, Poseidon hash) |
| `nullifier_hash.circom` | Deterministic nullifier derivation from secret |
| `poseidon.circom` | Poseidon hash wrapper (from circomlib) |
| `lib/commitment.circom` | Commitment hasher component |

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) >= 18
- [Circom](https://docs.circom.io/getting-started/installation/) 2.x
- [snarkjs](https://github.com/iden3/snarkjs)

### Install

```bash
npm install
```

### Compile Circuits

```bash
npm run compile
# or directly:
bash scripts/compile.sh
```

### Trusted Setup (Development Only)

```bash
npm run setup
```

⚠️ **WARNING:** The local setup is for development only. Production deployments require a multi-party computation (MPC) ceremony.

### Run Tests

```bash
npm test
```

### Export Verifier Keys

```bash
npm run export
```

## Security

The security of the protocol depends on:
1. The soundness of the Groth16 proof system
2. The collision resistance of Poseidon hash
3. The integrity of the trusted setup ceremony

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

Apache-2.0
