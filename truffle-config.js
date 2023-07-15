const HDWalletProvider = require('@truffle/hdwallet-provider');
const ALCHEMY_API_KEY = '';
const MNEMONIC = '';

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    // ... rest of your networks
    sepolia: {
      provider: () => new HDWalletProvider('donor prize march because explain that share damp convince derive method force', `https://sepolia.infura.io/v3/92084df1fafa48f8aebce1b1d71048f9`),
      network_id: "*",
      gas: 5500000,
      networkCheckTimeout: 1000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },

  compilers: {
    solc: {
      version: "0.8.3",
    },
  },
};
