const path = require("path");
const rootFolder = path.join(__dirname, "..", "..", "..");

const { createPublicClient, createWalletClient, http, encodeAbiParameters, keccak256, publicActions } = require("viem");
const { mnemonicToAccount, privateKeyToAccount } = require("viem/accounts");
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

    const account =
        wallet.type === "mnemonic"
            ? mnemonicToAccount(wallet.config.words, {
                  accountIndex: wallet.config.index || 0,
              })
            : privateKeyToAccount(wallet.config.key);

    console.log("Account Address:", account.address);

    const client = createWalletClient({
        account,
        chain,
        transport: http(network.rpcUrl),
    }).extend(publicActions);

    const proxyAddress = getProxyAddress(targetId);
    const contract = proxyAddress ? { address: proxyAddress, abi, client } : null;

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
    const cutData = require(path.resolve(cutFile));
    const abiParameters = [
        {
            type: "tuple[]",
            components: [
                { name: "facetAddress", type: "address" },
                { name: "action", type: "uint8" },
                { name: "functionSelectors", type: "bytes4[]" },
            ],
            name: "cuts",
        },
        { name: "initContractAddress", type: "address" },
        { name: "initData", type: "bytes" },
    ];

    const values = [
        cutData.cuts.map((cut) => ({
            facetAddress: cut.facetAddress,
            action: cut.action,
            functionSelectors: cut.functionSelectors,
        })),
        cutData.initContractAddress,
        cutData.initData,
    ];

    const encodedData = encodeAbiParameters(abiParameters, values);
    return keccak256(encodedData);
};

exports.enableUpgradeViaGovernance = async (targetId, cutFile) => {
    if (deployments[targetId].chainId === 1 || deployments[targetId].chainId === 8453 || deployments[targetId].chainId === 1313161554) {
        throw new Error("Only testnet upgrades can be automated!");
    }

    const { contract } = await loadTarget(targetId, "governance");

    const upgradeId = await exports.calculateUpgradeId(cutFile);
    console.log(`Enabling upgrade in contract, upgrade id: ${upgradeId}`);

    const [account] = await contract.client.getAddresses();

    const commonParams = {
        address: contract.address,
        abi: contract.abi,
        functionName: "createUpgrade",
        args: [upgradeId],
        account,
    };

    // Simulate and stop execution if revert
    await contract.client.simulateContract(commonParams);

    // Execute the actual contract call
    const tx = await contract.client.writeContract(commonParams);

    console.log(`Transaction: ${tx}`);
    console.log("Transaction mined!");
};

exports.assertUpgradeIdIsEnabled = async (targetId, upgradeId) => {
    const { client, contract } = await loadTarget(targetId);

    const val = await client.readContract({
        address: contract.address,
        abi: contract.abi,
        functionName: "getUpgrade",
        args: [upgradeId],
    });
    if (!val) {
        throw new Error(`Upgrade not found!`);
    }
};
