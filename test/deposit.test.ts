import { expect } from "chai";
// @ts-ignore — circom_tester has no type declarations
import { wasm as circomTester } from "circom_tester";
// @ts-ignore — circomlibjs has no type declarations
import { buildPoseidon } from "circomlibjs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Deposit Circuit", function () {
  this.timeout(120000);
  let circuit: any;
  let poseidon: any;

  before(async () => {
    poseidon = await buildPoseidon();
    circuit = await circomTester(
      path.join(__dirname, "../circuits/deposit.circom"),
      {
        include: [path.join(__dirname, "../node_modules")],
      }
    );
  });

  function hash(inputs: any[]) {
    const res = poseidon(inputs);
    return poseidon.F.toObject(res);
  }

  it("should compute a valid commitment from secret, amount, and tokenId", async () => {
    const input = {
      secret: "12345",
      amount: "1000000",
      tokenId: "1",
    };

    const expectedCommitment = hash([input.secret, input.amount, input.tokenId]);

    const witness = await circuit.calculateWitness(input);
    await circuit.checkConstraints(witness);
    
    // Check output commitment
    await circuit.assertOut(witness, { commitment: expectedCommitment });
  });
});
