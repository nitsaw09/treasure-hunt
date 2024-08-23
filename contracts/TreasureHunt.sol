// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TreasureHunt {
    // Define constants for grid size and total number of grid positions (10x10 grid)
    uint8 constant GRID_SIZE = 10;
    uint8 constant GRID_TOTAL = GRID_SIZE * GRID_SIZE;
    
    // State variables to track the position of the treasure and player positions
    uint8 treasurePosition;
    mapping(address => uint8) public playerPositions;
    uint256 public prizePool;
    
    // Events to log when a player moves and when a player wins
    event Moved(address player, uint8 newPosition, uint8 treasurePosition);
    event Won(address winner, uint256 reward);

    // Constructor to initialize the treasure's position based on the hash of the block number
    constructor() {
        treasurePosition = uint8(uint256(blockhash(block.number - 1)) % GRID_TOTAL);
    }
    
    // Modifier to ensure a valid move within the grid boundaries
    modifier validMove(uint8 newPosition) {
        require(newPosition < GRID_TOTAL, "Invalid grid position");
        _;
    }
    
    // Function for players to move to a new position
    function move(uint8 newPosition) external payable validMove(newPosition) {
        require(msg.value != 0, "ETH required to play");  // Ensure ETH is sent with the move
        require(isAdjacent(playerPositions[msg.sender], newPosition), "Move to adjacent position");

        playerPositions[msg.sender] = newPosition;  // Update player position
        prizePool += msg.value;  // Increase prize pool with player's ETH

        moveTreasure(newPosition);  // Move treasure based on player's move

        // Check if the player has found the treasure
        if (newPosition == treasurePosition) {
            uint256 reward = (prizePool * 90) / 100;  // Calculate 90% of the prize pool as reward
            prizePool = prizePool - reward;  // Deduct reward from prize pool
            payable(msg.sender).transfer(reward);  // Transfer reward to the winner
            emit Won(msg.sender, reward);  // Emit event for winning
        } else {
            emit Moved(msg.sender, newPosition, treasurePosition);  // Emit event for player move
        }
    }

    // Internal function to move the treasure based on player's new position
    function moveTreasure(uint8 playerPosition) internal {
        if (playerPosition % 5 == 0) {
            // If the player moves to a position that's a multiple of 5, move treasure to a random adjacent position
            treasurePosition = getRandomAdjacent(treasurePosition);
        } else if (isPrime(playerPosition)) {
            // If the player moves to a prime number, move treasure to a new random position on the grid
            treasurePosition = uint8(uint256(blockhash(block.number - 1)) % GRID_TOTAL);
        }
    }
    
    // Internal function to get a random adjacent position for the treasure
    function getRandomAdjacent(uint8 position) internal view returns (uint8) {
        uint8[4] memory adjacents;  // Array to store possible adjacent positions
        uint8 index = 0;

        // Calculate possible adjacent positions (up, down, left, right) and add them to the array
        if (position % GRID_SIZE != 0) adjacents[index++] = position - 1; // Up
        if ((position + 1) % GRID_SIZE != 0) adjacents[index++] = position + 1; // Down
        if (position - GRID_SIZE > 0) adjacents[index++] = position - GRID_SIZE; // Left
        if (position + GRID_SIZE < GRID_TOTAL) adjacents[index++] = position + GRID_SIZE; // Right
        
        // Check if there are any adjacent positions
        if (index == 0) {
            // If not, return the current position
            return position;
        }

        // Return a random adjacent position based on the blockhash
        return adjacents[uint8(uint256(blockhash(block.number - 1)) % index)];
    }
    
    // Internal function to check if a move is to an adjacent position
    function isAdjacent(uint8 from, uint8 to) internal pure returns (bool) {
        if (from == to) return false;  // The same position is not considered adjacent

        // check the ajacent position for from and to are zero
        if (from == 0 && to == GRID_SIZE) return true;
        if (from == GRID_SIZE && to == 0) return true; 

        // Check if the positions are adjacent vertically
        if (from + 1 == to && from % GRID_SIZE != GRID_SIZE - 1) return true; // Down
        if (from != 0 && from - 1 == to && from % GRID_SIZE != 0) return true; // Up

        // Check if the positions are adjacent horizontally
        if (from + GRID_SIZE == to && from < GRID_TOTAL - GRID_SIZE) return true; // right
        if (from > GRID_SIZE && from - GRID_SIZE == to && from >= GRID_SIZE) return true; // left

        return false;
    }
    
    // Internal function to check if a number is prime
    function isPrime(uint8 number) internal pure returns (bool) {
        if (number < 2) return false;  // 0 and 1 are not prime
        for (uint8 i = 2; i <= number / 2; i++) {
            if (number % i == 0) return false;  // Not prime if divisible by any number other than 1 and itself
        }
        return true;
    }
}
