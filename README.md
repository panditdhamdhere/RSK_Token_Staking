# Token Staking Smart Contract (Rootstock/Foundry)

This project implements a simple ERC20 token and a staking contract, allowing users to stake tokens and earn rewards. Built with [Foundry](https://book.getfoundry.sh/) and designed for deployment on the [Rootstock](https://rootstock.io/) (RSK) network.

## Features
- **ERC20 Token**: Mintable staking token (`StakingToken`)
- **Staking Contract**: Stake, withdraw, and earn rewards (`StakingContract`)
- **Comprehensive Tests**: Written in Solidity using Foundry's test framework
- **Deployment Script**: Easily deploy both contracts to Rootstock or any EVM-compatible network
- **Emergency Pause**: Owner can pause/unpause staking operations
- **Minimum Stake**: Configurable minimum stake amount
- **Reward Duration**: Configurable reward distribution period

---

## Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`)
- Node.js (for some RPC providers, optional)
- Rootstock wallet with testnet/mainnet funds for deployment

---

## Installation

```sh
git clone <this-repo-url>
cd t_Staking
forge install
```

---

## Contracts Overview

### 1. StakingToken (`src/StakingToken.sol`)
- ERC20 token with minting capability (owner only)
- Used as the staking asset

### 2. StakingContract (`src/StakingContract.sol`)
- Users stake `StakingToken` to earn rewards
- Owner can set the reward rate
- Rewards are distributed proportionally to stakers over time
- Emergency pause functionality
- Configurable minimum stake amount
- Adjustable reward duration

---

## Testing

Run all tests:
```sh
forge test
```
image.png

All tests are in `test/StakingTest.t.sol` and cover:
- Staking
- Withdrawing
- Reward accrual and claiming
- Full exit (withdraw + claim)
- Emergency pause
- Minimum stake requirements
- Reward duration settings

---

## Deployment

### 1. Configure Environment
Create a `.env` file in the project root:
```
PRIVATE_KEY=your_private_key_here
ROOTSTOCK_RPC_URL=https://public-node.rsk.co
```
- `PRIVATE_KEY`: Deployer's private key (keep it safe!)
- `ROOTSTOCK_RPC_URL`: Rootstock RPC endpoint (public or from a provider)

### 2. Deploy Contracts

```sh
forge script script/Deploy.s.sol:Deploy --rpc-url $ROOTSTOCK_RPC_URL --private-key $PRIVATE_KEY --broadcast
```
- This will deploy both `StakingToken` and `StakingContract` and print their addresses.

---

## Usage

### Staking
1. Approve the staking contract to spend your tokens:
   ```solidity
   stakingToken.approve(stakingContractAddress, amount);
   ```
2. Stake tokens (must be above minimum stake):
   ```solidity
   stakingContract.stake(amount);
   ```

### Withdrawing
```solidity
stakingContract.withdraw(amount);
```

### Claiming Rewards
```solidity
stakingContract.getReward();
```

### Exiting (Withdraw + Claim)
```solidity
stakingContract.exit();
```

### Owner Functions
```solidity
// Set minimum stake amount
stakingContract.setMinimumStake(amount);

// Set reward duration
stakingContract.setDuration(duration);

// Set reward rate
stakingContract.setRewardRate(rate);

// Emergency pause
stakingContract.pause();

// Resume operations
stakingContract.unpause();
```

---

## Customization
- **Reward Rate**: Owner can set the reward rate via `setRewardRate(uint256)`
- **Token Supply**: Owner can mint more tokens if needed
- **Minimum Stake**: Owner can adjust the minimum stake amount
- **Reward Duration**: Owner can modify the reward distribution period

---

## Security Notes
- The staking contract must be funded with enough tokens to pay out rewards. The deployment script and tests mint tokens to the contract for this purpose.
- Only the owner can mint new tokens, set the reward rate, minimum stake, duration, and pause/unpause the contract.
- The contract includes reentrancy protection and proper access control.

---

## Rootstock Network Resources
- [Rootstock Docs](https://developers.rsk.co/)
- [Rootstock Faucet (Testnet)](https://faucet.rsk.co/)
- [Rootstock Block Explorer](https://explorer.rsk.co/)

---

## License
MIT
