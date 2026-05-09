import { expect } from "chai";
// @ts-ignore — circom_tester has no type declarations
import { wasm as circomTester } from "circom_tester";
import path from "path";

describe("Deposit Circuit", () => {
  let circuit: any;

  before(async () => {
    circuit = await circomTester(
      path.join(__dirname, "../circuits/deposit.circom"),
      {
        include: [path.join(__dirname, "../node_modules")],
      }
    );
  });

  it("should compute a valid commitment from secret, nullifierSecret, and amount", async () => {
    const input = {
      secret: "12345",
      nullifierSecret: "67890",
      amount: "1000000",
    };

    const witness = await circuit.calculateWitness(input, true);
    await circuit.checkConstraints(witness);

    // The commitment (output signal) should be non-zero
    const commitment = witness[1]; // First output signal
    expect(commitment.toString()).to.not.equal("0");
  });

  it("should produce different commitments for different secrets", async () => {
    const input1 = {
      secret: "11111",
      nullifierSecret: "22222",
      amount: "1000000",
    };

    const input2 = {
      secret: "33333",
      nullifierSecret: "22222",
      amount: "1000000",
    };

    const witness1 = await circuit.calculateWitness(input1, true);
    const witness2 = await circuit.calculateWitness(input2, true);

    const commitment1 = witness1[1];
    const commitment2 = witness2[1];

    expect(commitment1.toString()).to.not.equal(commitment2.toString());
  });

  it("should produce different commitments for different amounts", async () => {
    const input1 = {
      secret: "11111",
      nullifierSecret: "22222",
      amount: "1000000",
    };

    const input2 = {
      secret: "11111",
      nullifierSecret: "22222",
      amount: "2000000",
    };

    const witness1 = await circuit.calculateWitness(input1, true);
    const witness2 = await circuit.calculateWitness(input2, true);

    expect(witness1[1].toString()).to.not.equal(witness2[1].toString());
  });

  it("should produce deterministic commitments for the same inputs", async () => {
    const input = {
      secret: "12345",
      nullifierSecret: "67890",
      amount: "1000000",
    };

    const witness1 = await circuit.calculateWitness(input, true);
    const witness2 = await circuit.calculateWitness(input, true);

    expect(witness1[1].toString()).to.equal(witness2[1].toString());
  });
});
