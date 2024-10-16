#!/usr/bin/env node

const chalk = require("chalk");
const yargs = require("yargs");
const { $ } = require("./utils");

(async () => {
    const { argv } = yargs
        .option('id', {
            alias: 'u',
            description: 'Upgrade ID to approve',
            type: 'string',
            demandOption: true
        })
        .option('contract', {
            alias: 'c',
            description: 'Contract address',
            type: 'string',
            demandOption: true
        })
        .option('from', {
            alias: 'f',
            description: 'From address',
            type: 'string',
            default: '0x28b85ca97cbf8127b47def4570bf6d9fb1983e38'
        })
        .option('newOwner', {
            alias: 'n',
            description: 'Transfer ownership for approval to this new owner address',
            type: 'string',
            default: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
        });

    const rpcUrl = 'http://127.0.0.1:8545';

    console.log(chalk.blue('Approving upgrade...'));

    // Impersonate account and create upgrade
    await $(`cast rpc anvil_impersonateAccount ${argv.from}`);
    await $(`cast send ${argv.contract} "createUpgrade(bytes32)" '${argv.id}' --rpc-url ${rpcUrl} --unlocked --from ${argv.from}`);

    console.log(chalk.green('Upgrade approved successfully!'));

    if (argv.newOwner) {
        console.log(chalk.blue('Transferring ownership...'));

        // Impersonate account and transfer ownership
        await $(`cast rpc anvil_impersonateAccount ${argv.from}`);
        await $(`cast send ${argv.contract} "transferOwnership(address)" '${argv.newOwner}' --rpc-url ${rpcUrl} --unlocked --from ${argv.from}`);

        console.log(chalk.green('Ownership transferred successfully!'));
    }

    console.log(chalk.green('Done!'));
})();

