const path = require("path");
const rootFolder = path.join(__dirname, "..", "..", "..");

const { createPublicClient, createWalletClient, http, encodeFunctionData, keccak256 } = require("viem");
const { mainnet, baseSepolia, base, sepolia, aurora, auroraTestnet } = require("viem/chains");
const config = require(path.join(rootFolder, "gemforge.config.cjs"));
const deployments = require(path.join(rootFolder, "gemforge.deployments.json"));
const { abi } = require(path.join(rootFolder, "out/IDiamondProxy.sol/IDiamondProxy.json"));

// Mapping of chain IDs to chain objects
const chainMap = {
    1: mainnet,
    11155111: sepolia,
    8453: base,
    84532: baseSepolia,
    1313161554: aurora,
    1313161555: auroraTestnet,
};

const getChainFromRpcUrl = async (rpcUrl) => {
    const client = createPublicClient({
        transport: http(rpcUrl),
    });
    const chainId = await client.getChainId();
    return chainMap[chainId];
};

const loadTarget = (exports.loadTarget = async (targetId, walletIdAttr) => {
    const networkId = config.targets[targetId].network;
    const network = config.networks[networkId];
    const walletId = config.targets[targetId][walletIdAttr || "wallet"];
    const wallet = config.wallets[walletId];

    const chain = await getChainFromRpcUrl(network.rpcUrl);

    const client = createPublicClient({
        chain,
        transport: http(network.rpcUrl),
    });

    const walletClient =
        wallet.type === "mnemonic"
            ? createWalletClient({
                  mnemonic: wallet.config.words,
                  path: `m/44'/60'/0'/0/${wallet.config.index || 0}`,
                  transport: http(network.rpcUrl),
              })
            : createWalletClient({
                  privateKey: wallet.config.key,
                  transport: http(network.rpcUrl),
              });

    const proxyAddress = getProxyAddress(targetId);
    const contract = proxyAddress ? { address: proxyAddress, abi, client: walletClient } : null;

    return {
        networkId,
        network,
        walletId,
        wallet,
        proxyAddress,
        client,
        contract,
    };
});

const getProxyAddress = (exports.getProxyAddress = (targetId) => {
    return deployments[targetId]?.contracts.find((a) => a.name === "DiamondProxy")?.onChain.address;
});

exports.calculateUpgradeId = async (cutFile) => {
    const cutData = require(cutFile);
    const encodedData = encodeFunctionData({
        abi: [
            {
                type: "function",
                name: "calculateUpgradeId",
                inputs: [
                    {
                        components: [
                            { name: "facetAddress", type: "address" },
                            { name: "action", type: "uint8" },
                            { name: "functionSelectors", type: "bytes4[]" },
                        ],
                        name: "cuts",
                        type: "tuple[]",
                    },
                    { type: "address", name: "initContractAddress" },
                    { type: "bytes", name: "initData" },
                ],
            },
        ],
        functionName: "calculateUpgradeId",
        args: [cutData.cuts, cutData.initContractAddress, cutData.initData],
    });
    return keccak256(encodedData);
};

exports.enableUpgradeViaGovernance = async (targetId, cutFile) => {
    if (deployments[targetId].chaiId === 1 || deployments[targetId].chaiId === 8453) {
        throw new Error("Only testnet upgrades can be automated!");
    }

    const { contract } = await loadTarget(targetId, "governance");

    const upgradeId = await exports.calculateUpgradeId(cutFile);
    console.log(`Enabling upgrade in contract, upgrade id: ${upgradeId}`);

    const tx = await contract.client.writeContract({
        address: contract.address,
        abi: contract.abi,
        functionName: "createUpgrade",
        args: [upgradeId],
    });
    console.log(`Transaction hash: ${tx.hash}`);

    await tx.wait();
    console.log("Transaction mined!");
};

exports.assertUpgradeIdIsEnabled = async (targetId, upgradeId) => {
    const { contract } = await loadTarget(targetId);
    const val = await contract.client.readContract({
        address: contract.address,
        abi: contract.abi,
        functionName: "getUpgrade",
        args: [upgradeId],
    });
    if (!val) {
        throw new Error(`Upgrade not found!`);
    }
};
