const Token = artifacts.require("token");
const DynamicCashPool = artifacts.require("DynamicCashPool"); // updated this line

module.exports = function (deployer) {
    deployer.deploy(Token);
    deployer.deploy(DynamicCashPool); // updated this line
};
