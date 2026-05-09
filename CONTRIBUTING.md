# Contributing to shielded-circuits

Welcome! We're thrilled that you want to contribute to the ZK circuits of the Shielded Protocol.

## Contributor Tracks

### 1. ZK Circuits (Circom)
- Setup: Install `circom` and `snarkjs`.
- Test: `npm install && npm test`
- Good issues: Look for `layer:circuits` labels.

### 2. Smart Contracts (Rust)
- Head over to `shielded-contracts`.
- Good issues: Look for `layer:contracts`.

### 3. SDK & Frontend (TypeScript)
- Head over to `shielded-sdk` or `shielded-app`.
- Good issues: Look for `layer:sdk` or `layer:app`.

## Your First PR

1. Fork the repo.
2. Create a branch: `git checkout -b feat/my-circuit-change`.
3. Make your changes and add tests.
4. Run `npm run compile` to ensure circuits are valid.
5. Submit a PR!

## PR Checklist

- [ ] Circuits compile without errors
- [ ] All tests pass (`npm test`)
- [ ] No unused signals or constraints
- [ ] Issue linked

## Code of Conduct

We follow the Contributor Covenant. Be kind and professional.

## Wave Contributors

Check out [Wave-ready issues](../../issues?q=label%3Astatus%3Awave-ready) to earn points!
