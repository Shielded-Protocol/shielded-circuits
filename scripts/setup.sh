#!/usr/bin/env bash
set -euo pipefail

# Trusted setup ceremony for all circuits.
# Phase 1: Powers of Tau (universal, shared across circuits)
# Phase 2: Circuit-specific setup
#
# ⚠️ WARNING: This uses a LOCAL setup for development only.
# For production, use a multi-party computation (MPC) ceremony.
#
# Requires: snarkjs installed globally or via npx

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
KEYS_DIR="$ROOT_DIR/keys"

mkdir -p "$KEYS_DIR"

POWER=15  # 2^15 = 32768 constraints (sufficient for our circuits)

echo "═══════════════════════════════════════════"
echo "  Phase 1: Powers of Tau (BN254)"
echo "═══════════════════════════════════════════"

if [ ! -f "$KEYS_DIR/pot${POWER}_final.ptau" ]; then
    npx snarkjs powersoftau new bn128 "$POWER" "$KEYS_DIR/pot${POWER}_0000.ptau" -v
    npx snarkjs powersoftau contribute "$KEYS_DIR/pot${POWER}_0000.ptau" "$KEYS_DIR/pot${POWER}_0001.ptau" \
        --name="First contribution" -v -e="$(head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    npx snarkjs powersoftau prepare phase2 "$KEYS_DIR/pot${POWER}_0001.ptau" "$KEYS_DIR/pot${POWER}_final.ptau" -v
    echo "✅ Powers of Tau ceremony complete"
else
    echo "⏩ Powers of Tau already exists, skipping"
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Phase 2: Circuit-specific setup"
echo "═══════════════════════════════════════════"

CIRCUITS=("deposit" "withdraw")

for circuit in "${CIRCUITS[@]}"; do
    echo ""
    echo "🔧 Setting up $circuit..."
    
    if [ ! -f "$BUILD_DIR/${circuit}.r1cs" ]; then
        echo "❌ R1CS not found for $circuit. Run compile.sh first."
        exit 1
    fi

    npx snarkjs groth16 setup \
        "$BUILD_DIR/${circuit}.r1cs" \
        "$KEYS_DIR/pot${POWER}_final.ptau" \
        "$KEYS_DIR/${circuit}_0000.zkey"

    npx snarkjs zkey contribute \
        "$KEYS_DIR/${circuit}_0000.zkey" \
        "$KEYS_DIR/${circuit}_final.zkey" \
        --name="First contribution" -v -e="$(head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')"

    npx snarkjs zkey export verificationkey \
        "$KEYS_DIR/${circuit}_final.zkey" \
        "$KEYS_DIR/${circuit}_verification_key.json"

    echo "✅ $circuit setup complete"
done

echo ""
echo "🎉 All circuit setups complete!"
echo "   Keys directory: $KEYS_DIR"
