# shielded-circuits

> ZK circuits for the Shielded Protocol, built with Circom.

Part of [shielded-protocol](https://github.com/Shielded-Protocol) — 
private, compliant DeFi on Stellar.

[![CI](https://github.com/Shielded-Protocol/shielded-circuits/actions/workflows/ci.yml/badge.svg)](https://github.com/Shielded-Protocol/shielded-circuits/actions)
[![Stellar Wave](https://img.shields.io/badge/Stellar-Wave-blue)](https://drips.network/wave/stellar)

## What this does

These circuits implement the zero-knowledge proof system (Groth16 over BN254) that powers private transactions on Stellar Soroban. Users generate proofs off-chain using these circuits, which are then verified on-chain by the `groth16-verifier` contract.

The repository includes circuits for deposits, withdrawals, Merkle inclusion proofs, and nullifier derivation.

## Quickstart

```bash
npm install
npm run compile
npm test
```

## Architecture

[Link to shielded-docs](https://github.com/Shielded-Protocol/shielded-docs)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).  
Browse [Wave-ready issues](../../issues?q=label%3Astatus%3Awave-ready).

## License

MIT
