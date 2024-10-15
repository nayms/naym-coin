#!/usr/bin/env node

const chalk = require("chalk");
const path = require("path");
const fs = require("fs");
const rootFolder = path.join(__dirname, "..", "..");
const config = require(path.join(rootFolder, "gemforge.config.cjs"));

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
        return await execa.command(cmd, {
            ...opts,
            shell: true,
            stdio: "inherit",
            cwd: rootFolder,
        });
    };

    const args = process.argv.slice(2);

    const targetArg = args[0];

    if (!targetArg) {
        throw new Error(`Please specify a target!`);
    }

    const actionArg = args[1];

    if (!actionArg) {
        throw new Error("Expecting one of: --fresh, --upgrade-start, --upgrade-finish");
    }

    const options = {};

    // Parse additional options
    for (let i = 2; i < args.length; i++) {
        const arg = args[i];
        if (arg.startsWith("--")) {
            const key = arg.slice(2);
            const value = args[i + 1] && !args[i + 1].startsWith("--") ? args[i + 1] : true;
            options[key] = value;
            if (value !== true) {
                i++;
            }
        }
    }

    const cutFile = path.join(rootFolder, ".gemforge/cut.json");

    await _showTargetInfo(targetArg);

    switch (actionArg) {
        case "--dry": {
            console.log("Dry-run Deployment");
            await $(`yarn gemforge deploy ${targetArg} --dry`);
            break;
        }
        case "--fresh": {
            console.log(`Fresh Deploy`);
            await $(`yarn gemforge deploy ${targetArg} -n`);
            break;
        }
        case "--upgrade-start": {
            console.log(`Upgrade - Deploy Facets`);
            if (fs.existsSync(cutFile)) {
                fs.unlinkSync(cutFile);
            }

            let deployCmd = `yarn gemforge deploy ${targetArg} --pause-cut-to-file ${cutFile}`;

            if (options["upgrade-init-contract"]) {
                deployCmd += ` --upgrade-init-contract ${options["upgrade-init-contract"]}`;
            }
            if (options["upgrade-init-method"]) {
                deployCmd += ` --upgrade-init-method ${options["upgrade-init-method"]}`;
            }

            await $(deployCmd);

            if (!fs.existsSync(cutFile)) {
                console.log(`No upgrade necessary!`);
            } else {
                await tellUserToEnableUpgrade(targetArg, cutFile);
            }
            break;
        }
        case "--upgrade-finish": {
            console.log(`Upgrade - Diamond Cut`);
            if (!fs.existsSync(cutFile)) {
                throw new Error(`Cut JSON file not found - please run the first upgrade step first!`);
            }
            if (targetArg !== "mainnet" && targetArg !== "mainnetFork" && targetArg !== "base" && targetArg !== "baseFork") {
                await enableUpgradeViaGovernance(targetArg, cutFile);
            }
            await assertThatUpgradeIsEnabled(targetArg, cutFile);

            let deployCmd = `yarn gemforge deploy ${targetArg} --resume-cut-from-file ${cutFile}`;

            if (options["upgrade-init-contract"]) {
                deployCmd += ` --upgrade-init-contract ${options["upgrade-init-contract"]}`;
            }
            if (options["upgrade-init-method"]) {
                deployCmd += ` --upgrade-init-method ${options["upgrade-init-method"]}`;
            }

            await $(deployCmd);
            break;
        }
        default: {
            throw new Error("Expecting one of: --fresh, --upgrade-start, --upgrade-finish");
        }
    }

    console.log(`Done!`);
})();
