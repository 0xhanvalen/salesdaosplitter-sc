const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Splitter", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deploySplitters() {
    // Contracts are deployed using the first signer/account by default
    const [owner, treasury, signer, salesman, customer] =
      await ethers.getSigners();

    const SplitterFactory = await ethers.getContractFactory("SplitterFactory");
    const splitterFactory = await SplitterFactory.deploy(
      treasury.address,
      signer.address
    );

    await splitterFactory.deployed();

    await splitterFactory.createSplit(salesman.address);
    const splitterAddress = await splitterFactory.splittersAddressesByRecipient(
      salesman.address
    );

    return { owner, treasury, signer, salesman, customer, splitterFactory };
  }

  describe("Deployment", function () {
    it("Should deploy the splitter factory", async function () {
      const { splitterFactory } = await loadFixture(deploySplitters);

      expect(splitterFactory.address).to.be.properAddress;
    });
  });
});
