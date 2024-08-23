// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../TreasureHunt.sol"; 

contract TreasureHuntMock is TreasureHunt {
    // Allow setting the treasure position manually for testing
    function setTreasurePosition(uint8 _position) external {
        treasurePosition = _position;
    }

    // Allow setting the player position manually for testing
    function setPlayerPosition(address _player, uint8 _position) external {
        playerPositions[_player] = _position;
    }

    // Allow setting the prize pool manually for testing
    function setPrizePool(uint256 _amount) external {
        prizePool = _amount;
    }

    // Get the treasure position for testing
    function getTreasurePosition() external view returns (uint8) {
        return treasurePosition;
    }

    // check the postion is adjacent for testing
    function isAdjacentPosition(uint8 _from, uint8 _to) external pure returns (bool) {
        return isAdjacent(_from, _to);
    }
}
