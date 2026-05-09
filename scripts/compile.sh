#!/usr/bin/env bash
set -euo pipefail

# Compile all circuits, generating R1CS and WASM artifacts.
# Requires: circom 2.x installed and available in PATH.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CIRCUITS_DIR="$ROOT_DIR/circuits"
BUILD_DIR="$ROOT_DIR/build"

mkdir -p "$BUILD_DIR"

CIRCUITS=("deposit" "withdraw")

for circuit in "${CIRCUITS[@]}"; do
    echo "🔧 Compiling $circuit.circom..."
    circom "$CIRCUITS_DIR/$circuit.circom" \
        --r1cs \
        --wasm \
        --sym \
        --output "$BUILD_DIR" \
        -l "$ROOT_DIR/node_modules"
    
    echo "✅ $circuit compiled successfully"
    echo "   R1CS:  $BUILD_DIR/${circuit}.r1cs"
    echo "   WASM:  $BUILD_DIR/${circuit}_js/${circuit}.wasm"
    echo ""
done

echo "🎉 All circuits compiled successfully!"
