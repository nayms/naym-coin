require("dotenv").config();

const fs = require("fs");
const { mnemonicToAccount } = require("viem/accounts");

const MNEMONIC = fs.existsSync("./nayms_mnemonic.txt") ? fs.readFileSync("./nayms_mnemonic.txt").toString().trim() : "test test test test test test test test test test test junk";

const sysAdminAddress = mnemonicToAccount(MNEMONIC).address;
const mainnetSysAdminAddress = process.env.NAYM_SYS_ADMIN_ADDRESS;

console.log("The sysAdminAddress is: ", sysAdminAddress);
console.log("The mainnetSysAdminAddress is: ", mainnetSysAdminAddress);
module.exports = {
  // Configuration file version
  version: 2,
  // Compiler configuration
  solc: {
    // SPDX License - to be inserted in all generated .sol files
    license: "MIT",
    // Solidity compiler version - to be inserted in all generated .sol files
    version: "0.8.20",
  },
  // commands to execute
  commands: {
    // the build command
    build: "forge build",
  },
  paths: {
    // contract built artifacts folder
    artifacts: "out",
    // source files
    src: {
      // file patterns to include in facet parsing
      facets: [
        // include all .sol files in the facets directory ending "Facet"
        "src/facets/*Facet.sol",
      ],
    },
    // folders for gemforge-generated files
    generated: {
      // output folder for generated .sol files
      solidity: "src/generated",
      // output folder for support scripts and files
      support: ".gemforge",
      // deployments JSON file
      deployments: "gemforge.deployments.json",
    },
    // library source code
    lib: {
      // diamond library
      diamond: "lib/diamond-2-hardhat",
    },
  },
  // artifacts configuration
  artifacts: {
    // artifact format - "foundry" or "hardhat"
    format: "foundry",
  },
  // generator options
  generator: {
    // proxy interface options
    proxyInterface: {
      // imports to include in the generated IDiamondProxy interface
      imports: ["src/shared/FreeStructs.sol"],
    },
  },
  // diamond configuration
  diamond: {
    // Whether to include public methods when generating the IDiamondProxy interface. Default is to only include external methods.
    publicMethods: true,
    init: {
      contract: "InitDiamond",
      function: "init",
    },
    // Names of core facet contracts - these will not be modified/removed once deployed and are also reserved names.
    // This default list is taken from the diamond-2-hardhat library.
    // NOTE: WE RECOMMEND NOT CHANGING ANY OF THESE EXISTING NAMES UNLESS YOU KNOW WHAT YOU ARE DOING.
    coreFacets: ["DiamondCutFacet", "DiamondLoupeFacet", "NaymsOwnershipFacet", "ACLFacet", "GovernanceFacet"],
  },
  // lifecycle shell command hooks
  hooks: {
    preBuild: "",
    postBuild: "",
    preDeploy: "",
    postDeploy: "./script/gemforge/verify.js",
  },
  // Wallets to use for deployment
  wallets: {
    // nayms owner
    devOwnerWallet: {
      type: "mnemonic",
      config: {
        words: MNEMONIC,
        index: 19,
      },
    },
    // nayms sys admin
    devSysAdminWallet: {
      type: "mnemonic",
      config: {
        words: MNEMONIC,
        index: 0,
      },
    },
    deployerWallet: {
      type: "private-key",
      config: {
        key: process.env.NAYM_TOKEN_DEPLOYER_KEY || "",
      },
    },
  },
  networks: {
    local: { rpcUrl: "http://localhost:8545" },
    sepolia: {
      rpcUrl: process.env.ETH_SEPOLIA_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://api-sepolia.etherscan.io/api",
          apiKey: () => process.env.ETHERSCAN_API_KEY,
        },
      },
    },
    mainnet: {
      rpcUrl: process.env.ETH_MAINNET_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://api.etherscan.io/api",
          apiKey: () => process.env.ETHERSCAN_API_KEY,
        },
      },
    },
    baseSepolia: {
      rpcUrl: process.env.BASE_SEPOLIA_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://api-sepolia.basescan.org/api",
          apiKey: () => process.env.BASESCAN_API_KEY,
        },
      },
    },
    base: {
      rpcUrl: process.env.BASE_MAINNET_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://api.basescan.org/api",
          apiKey: () => process.env.BASESCAN_API_KEY,
        },
      },
    },
    aurora: {
      rpcUrl: process.env.AURORA_MAINNET_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://explorer.mainnet.aurora.dev/api",
          apiKey: () => process.env.BLOCKSCOUT_API_KEY,
        },
      },
    },
    auroraTestnet: {
      rpcUrl: process.env.AURORA_TESTNET_RPC_URL,
      contractVerification: {
        foundry: {
          apiUrl: "https://explorer.testnet.aurora.dev/api",
          apiKey: () => process.env.BLOCKSCOUT_API_KEY,
        },
      },
    },
  },
  targets: {
    // `governance` attribute is only releveant for testnets, it's a wallet to use to auto approve the upgrade ID within the script
    local: { network: "local", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    sepolia: { network: "sepolia", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    sepoliaFork: { network: "local", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    mainnet: { network: "mainnet", wallet: "deployerWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    mainnetFork: { network: "local", wallet: "deployerWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    baseSepolia: { network: "baseSepolia", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    baseSepoliaFork: { network: "local", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    base: { network: "base", wallet: "deployerWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    baseFork: { network: "local", wallet: "deployerWallet", governance: "devSysAdminWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    baseForkDev: { network: "local", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    aurora: { network: "aurora", wallet: "deployerWallet", initArgs: [mainnetSysAdminAddress], create3Salt: process.env.NAYM_TOKEN_SALT },
    auroraFork: { network: "local", wallet: "devOwnerWallet", initArgs: [mainnetSysAdminAddress] },
    auroraTestnet: { network: "auroraTestnet", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
    auroraTestnetFork: { network: "local", wallet: "devOwnerWallet", governance: "devSysAdminWallet", initArgs: [sysAdminAddress] },
  },
};
