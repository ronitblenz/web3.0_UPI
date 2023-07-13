const { expect } = require("chai");
const ethers = require('ethers');

describe("DynamicCashPool", function() {
  it("Should return the right balance after contribution", async function() {
    // Define your constructor arguments
    const lockupPeriod = 1000; // Replace with your desired lockup period
    const rebalanceInterval = 1000; // Replace with your desired rebalance interval
    const amount = ethers.utils.parseEther("1"); // Commented out for now

    // Get the Signer to simulate the contract deployment and interaction
    const [owner] = await ethers.getSigners();

    // Suppose 'Token' is your ERC20 token contract
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();  // You might need constructor arguments for the token as well
    await token.deployed();

    // Get the token's address
    const tokenAddress = "0xD9E61879308e5A95d9475da286261E59F665693A";

    // Deploy the contract with arguments
    const DynamicCashPool = await ethers.getContractFactory("DynamicCashPool");
    const dynamicCashPool = await DynamicCashPool.deploy(lockupPeriod, rebalanceInterval);
    await dynamicCashPool.deployed();

    // Before making a contribution, approve the DynamicCashPool to spend the tokens
    await token.connect(owner).approve(dynamicCashPool.address, amount); // Commented out for now

    // Use the tokenAddress in your function call
    await dynamicCashPool.connect(owner).contribute(tokenAddress, amount); // Commented out for now

    // Check the participant's balance
    expect(await dynamicCashPool.getParticipantBalance(owner.address, tokenAddress)).to.equal(amount); // Commented out for now
  });
});
