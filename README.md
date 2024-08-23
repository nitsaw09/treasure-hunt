# Treasure Hunt Smart Contract

## Overview

The Treasure Hunt smart contract is an on-chain game where multiple players compete to find a hidden treasure on a 10x10 grid. Players move across the grid by sending ETH with their moves, and the first player to find the treasure wins a significant portion of the accumulated prize pool.

## Smart Contract Details

### State Variables

1. **`GRID_SIZE`**: Constant representing the size of the grid (10x10).
2. **`GRID_TOTAL`**: Constant representing the total number of positions on the grid (100).
3. **`treasurePosition`**: Stores the current position of the treasure on the grid.
4. **`playerPositions`**: Mapping of player addresses to their current positions on the grid.
5. **`prizePool`**: Accumulated pool of ETH from player moves.

### Events

1. **`Moved(address player, uint8 newPosition, uint8 treasurePosition)`**: Emitted when a player moves to a new position on the grid.
2. **`Won(address winner, uint256 reward)`**: Emitted when a player finds the treasure and wins the reward.

### Constructor

- **`constructor()`**: Initializes the treasure's position based on the block number hash at the time of contract deployment.

### Modifiers

1. **`validMove(uint8 newPosition)`**: Ensures that the player's move is within the valid grid boundaries.

### Functions

1. **`move(uint8 newPosition) external payable validMove(newPosition)`**: Allows a player to move to a new position on the grid. Players must send ETH to make a move, and the treasure's position may change based on the player's move. If a player finds the treasure, they receive 90% of the prize pool as a reward.
   
2. **`moveTreasure(uint8 playerPosition) internal`**: Internal function that moves the treasure to a new position based on the player's move. The treasure may move to a random adjacent position or to a new random position on the grid.

3. **`getRandomAdjacent(uint8 position) internal view returns (uint8)`**: Internal function that returns a random adjacent position on the grid.

4. **`isAdjacent(uint8 from, uint8 to) internal pure returns (bool)`**: Internal function that checks if two positions on the grid are adjacent.

5. **`isPrime(uint8 number) internal pure returns (bool)`**: Internal function that checks if a number is prime.

### How to Run

#### Environment Setup

- Ensure you have `Node.js` and npm installed on your machine.

#### Install Dependencies

- Run `npm install` to install the required dependencies.

#### Run Tests

- Execute `npx hardhat test` to run the provided tests and ensure the smart contract functions as expected.

### Deploy on Ethereum Network

- Update the `hardhat.config.js` file with your Ethereum network configuration.
- Run `npx hardhat run scripts/deploy.js --network <your-network>` to deploy the smart contract.
- Run `npx hardhat verify --network <your-network> <CONTRACT_ADDRESS>` to verify the smart contract.

### Libraries Used

1. **`Hardhat`**: Ethereum development environment for testing and deployment.
2. **`Ethers`**: JavaScript library for interacting with Ethereum smart contracts.

### Purpose of Libraries

1. **`Hardhat`**: Facilitates smart contract development, testing, and deployment.
2. **`Ethers`**: Provides a consistent interface for interacting with Ethereum smart contracts in JavaScript.
