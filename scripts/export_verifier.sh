#!/usr/bin/env bash
set -euo pipefail

# Export verifier keys for on-chain deployment.
# Generates verification keys in formats suitable for Soroban contracts.
#
# Requires: snarkjs, circuit setup already completed (run setup.sh first)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KEYS_DIR="$ROOT_DIR/keys"
EXPORT_DIR="$ROOT_DIR/export"

mkdir -p "$EXPORT_DIR"

CIRCUITS=("deposit" "withdraw")

for circuit in "${CIRCUITS[@]}"; do
    echo "📦 Exporting verifier for $circuit..."

    if [ ! -f "$KEYS_DIR/${circuit}_final.zkey" ]; then
        echo "❌ Final zkey not found for $circuit. Run setup.sh first."
        exit 1
    fi

    # Export Solidity verifier (reference implementation)
    npx snarkjs zkey export solidityverifier \
        "$KEYS_DIR/${circuit}_final.zkey" \
        "$EXPORT_DIR/${circuit}_verifier.sol"

    # Export verification key as JSON (for Soroban contract consumption)
    cp "$KEYS_DIR/${circuit}_verification_key.json" \
        "$EXPORT_DIR/${circuit}_vk.json"

    # Export call data format (useful for testing)
    echo "✅ $circuit verifier exported"
done

echo ""
echo "🎉 All verifiers exported to: $EXPORT_DIR"
echo ""
echo "Files:"
ls -la "$EXPORT_DIR"
