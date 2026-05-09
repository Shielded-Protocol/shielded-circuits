# Contributing to Shielded Circuits

## Development Setup

1. Install [Circom 2.x](https://docs.circom.io/getting-started/installation/)
2. Install Node.js >= 18
3. Run `npm install`
4. Run tests: `npm test`

## Circuit Design Guidelines

- Keep circuits minimal — fewer constraints = cheaper proofs
- Document all signals (inputs, outputs, intermediates)
- Use circomlib components where possible (don't reinvent Poseidon, etc.)
- Always check constraint counts after changes
- Write tests for all edge cases

## Pull Request Process

1. Fork and create a feature branch
2. Make changes with tests
3. Document constraint count changes
4. Submit PR using the template
