![Build status](https://github.com/nayms/naym-coin/actions/workflows/ci.yml/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/nayms/naym-coin/badge.svg?t=wvNXqi)](https://coveralls.io/github/nayms/naym-coin)

# naym-coin

The `NAYM` ERC-20 token.

Features:

* Has an owner that can be changed (`0x0` not allowed).
* Has changeable minter that is set by owner. Only the minter can mint new tokens.
* Anyone can burn their own tokens.

## On-chain addresses

_TODO: Live deployed addresses here_

## Developer guide

Install pre-requisites:

* [Foundry](https://book.getfoundry.sh/)
* [Yarn](https://yarnpkg.com/)

Then run:

```shell
$ yarn
```

To compile the contracts:

```shell
$ yarn build
```

To test:

```shell
$ yarn test
```

To run a local devnet:

```shell
$ yarn devnet
```

## Deployment

* _The `owner` and `minter` are both initially set to be the deployment wallet's address._
* _[CREATE2](https://book.getfoundry.sh/tutorials/create2-tutorial) is used for deployment, so the address will always be the same as long as the deployment wallet and bytecode are the same, irrespective of chain, nonce, etc._

### Local (anvil)

To deploy locally, first run a local devnet:

```shell
$ yarn devnet
```

Then run:

```shell
$ yarn deploy-local
```

### Public (tesnets, mainnets)

Set the following environment variables:

```shell
$ export PRIVATE_KEY="0x..."
$ export RPC_URL="http://..."
$ export CHAIN_ID="..."
```

Then run:

```shell
$ yarn deploy-public
```

## License

GPLv3 - see [LICENSE.md](LICENSE.md)

Naym-Coin smart contracts
Copyright (C) 2024  [Nayms](https://nayms.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
