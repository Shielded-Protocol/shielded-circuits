import { expect } from "chai";
// @ts-ignore — circom_tester has no type declarations
import { wasm as circomTester } from "circom_tester";
// @ts-ignore — circomlibjs has no type declarations
import { buildPoseidon } from "circomlibjs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Withdraw Circuit", function () {
  this.timeout(120000);
  let circuit: any;
  let poseidon: any;
  const LEVELS = 20;

  before(async () => {
    poseidon = await buildPoseidon();
    circuit = await circomTester(
      path.join(__dirname, "../circuits/withdraw.circom"),
      {
        include: [path.join(__dirname, "../node_modules")],
      }
    );
  });

  function hash(inputs: any[]) {
    const res = poseidon(inputs);
    return poseidon.F.toString(res);
  }

  it("should verify a valid withdrawal proof with correct Merkle path", async () => {
    const secret = "12345";
    const amount = "1000000";
    const tokenId = "1";

    // 1. Compute commitment
    const commitment = hash([secret, amount, tokenId]);

    // 2. Compute nullifier hash
    const nullifierHash = hash([secret]);

    // 3. Simple Merkle proof (empty tree except for our commitment at index 0)
    const pathElements = new Array(LEVELS).fill("0");
    const pathIndices = new Array(LEVELS).fill(0);

    // Compute root of this simple tree
    let root = commitment;
    for (let i = 0; i < LEVELS; i++) {
        root = hash([root, "0"]); // Since pathIndices[i] is 0, root is on the left
    }

    const input = {
      secret,
      amount,
      tokenId,
      pathElements,
      pathIndices,
      root,
      nullifierHash,
      recipient: "123456789",
      relayer: "0",
      fee: "0",
      refund: "0"
    };

    const witness = await circuit.calculateWitness(input);
    await circuit.checkConstraints(witness);
    
    // Check that the nullifierHash output matches (if it were an output, but it's a public input)
    // In withdraw.circom, nullifierHash is a public input and we constrain it.
  });
});
