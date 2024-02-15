# naym-coin

The `NAYM` ERC-20 token.

## On-chain addresses

_(Live deployed addresses here)_

## Developer guide

Install pre-requisites:

* [Foundry](https://book.getfoundry.sh/)
* [Bun](https://bun.sh)

Then run:

```shell
$ bun i
```

To build the contracts:

```shell
$ bun build
```

To test:

```shell
$ bun tests
```

To run a local devnet:

```shell
$ bun devnet
```

### Deployment

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## License

GPLv3 - see [LICENSE.md]

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
