#!/usr/bin/env node

const chalk = require("chalk");
const path = require("path");
const fs = require("fs");
const rootFolder = path.join(__dirname, "..", "..");
const config = require(path.join(rootFolder, "gemforge.config.cjs"));
const yargs = require("yargs");

const execa = require("execa");

const { getProxyAddress, calculateUpgradeId, assertUpgradeIdIsEnabled, enableUpgradeViaGovernance } = require("./utils");

const _showTargetInfo = async (targetId) => {
    console.log(`Target: ${targetId}`);
    console.log(`Network: ${config.targets[targetId].network}`);
    console.log(`Wallet: ${config.targets[targetId].wallet}`);
    console.log(`\nDiamond Proxy: ${chalk.green(getProxyAddress(targetId))}\n`);
};

const tellUserToEnableUpgrade = async (targetId, cutFile) => {
    const upgradeId = await calculateUpgradeId(cutFile);

    console.log(`\nUpgrade id: ${chalk.green(upgradeId)}\n`);

    if (targetId === "mainnet") {
        console.log(`Please log into the MPC and enable this upgrade!`);
    } else {
        console.log(`Please run the next upgrade step to complete the upgrade.`);
    }
};

const assertThatUpgradeIsEnabled = async (targetId, cutFile) => {
    const upgradeId = await calculateUpgradeId(cutFile);

    await assertUpgradeIdIsEnabled(targetId, upgradeId);
};

(async () => {
    const $ = async (cmd, opts = {}) => {
        if (typeof cmd !== "string") {
            throw new Error("Command must be a string");
        }
        return await execa.command(cmd, { ...opts, shell: true, stdio: "inherit", cwd: rootFolder });
    };

    const { argv } = yargs;

    const targetArg = argv._[0];

    if (!targetArg) {
        throw new Error(`Please specify a target!`);
    }

    const cutFile = path.join(rootFolder, ".gemforge/cut.json");

    await _showTargetInfo(targetArg);

    if (argv.dry) {
        console.log("Dry-run Deployment");
        await $(`yarn gemforge deploy ${targetArg} --dry`);
    } else if (argv.fresh) {
        console.log("Fresh Deployment");
        await $(`yarn gemforge deploy ${targetArg} -n`);
    } else if (argv.upgradeStart) {
        console.log("Upgrade - Deploy Facets");
        if (fs.existsSync(cutFile)) {
            fs.unlinkSync(cutFile);
        }
        const upgradeInitArgs = (argv.upgradeInitContract && argv.upgradeInitMethod) 
            ? `--upgrade-init-contract ${argv.upgradeInitContract} --upgrade-init-method ${argv.upgradeInitMethod}`
            : "";
        $(`yarn gemforge deploy ${targetArg} --pause-cut-to-file ${cutFile} ${upgradeInitArgs}`);
        if (!fs.existsSync(cutFile)) {
            console.log(`No upgrade necessary!`);
        } else {
            await tellUserToEnableUpgrade(targetArg, cutFile);
        }
    } else if (argv.upgradeFinish) {
        console.log("Upgrade - Diamond Cut");
        if (!fs.existsSync(cutFile)) {
            throw new Error(`Cut JSON file not found - please run the first upgrade step first!`);
        }
        if (targetArg !== "mainnet" && targetArg !== "mainnetFork" && targetArg !== "base" && targetArg !== "baseFork") {
            await enableUpgradeViaGovernance(targetArg, cutFile);
        }

        await assertThatUpgradeIsEnabled(targetArg, cutFile);
        await $(`yarn gemforge deploy ${targetArg} --resume-cut-from-file ${cutFile}`);
    } else {
        throw new Error("Expecting one of: --fresh, --upgrade-start, --upgrade-finish");
    }

    console.log(`Done!`);
})();
