const Token = artifacts.require('token');
const DynamicCashPool = artifacts.require('DynamicCashPool'); // updated this line

// ... rest of your test file


contract("DynamicCashPool", accounts => {
  it("Should return the right balance after contribution", async function() {
    // Define your constructor arguments
    const lockupPeriod = 1000; // Replace with your desired lockup period
    const rebalanceInterval = 1000; // Replace with your desired rebalance interval
    const amount = web3.utils.toWei("1", "ether");

    // Get the accounts provided by Truffle
    const owner = accounts[0];

    // Deploy the contracts
    let token = await Token.new();
    let dynamicCashPool = await DynamicCashPool.new(lockupPeriod, rebalanceInterval);

    // Before making a contribution, approve the DynamicCashPool to spend the tokens
    await token.approve(dynamicCashPool.address, amount, {from: owner});

    // Use the tokenAddress in your function call
    await dynamicCashPool.contribute(token.address, amount, {from: owner});

    // Check the participant's balance
    let balance = await dynamicCashPool.getParticipantBalance(owner, token.address);
    assert.equal(balance.toString(), amount);
  });
});
