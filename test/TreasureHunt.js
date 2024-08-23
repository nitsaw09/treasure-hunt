const { expect } = require("chai");
const { ethers } = require("hardhat");
const { anyValue } = require('@ethereum-waffle/chai');

describe("TreasureHunt", function () {
  let TreasureHuntMock, treasureHuntMock, owner, player1, player2;

  before(async () => {
    [owner, player1, player2] = await ethers.getSigners();
    TreasureHuntMock = await ethers.getContractFactory("TreasureHuntMock");
    treasureHuntMock = await TreasureHuntMock.deploy();
    await treasureHuntMock.deployed();
    await treasureHuntMock.connect(player1);
  });

  it("should set the treasure between 0 to 99 position on contract initialization", async () => {
    expect(await treasureHuntMock.getTreasurePosition()).to.greaterThanOrEqual(0);
    expect(await treasureHuntMock.getTreasurePosition()).to.lessThanOrEqual(99);
  });
  
  it("should revert a player move to invalid grid position", async () => {
    await expect(
      treasureHuntMock.move(101, { value: ethers.utils.parseEther("0.1") })
    ).to.be.revertedWith("Invalid grid position");
  });

  it("should revert a player move for insufficient eth", async () => {
    await expect(
      treasureHuntMock.move(1, { value: ethers.utils.parseEther("0") })
    ).to.be.revertedWith("ETH required to play");
  });

  it("should have initial position zero for player", async () => {
    const initialPlayerPosition = await treasureHuntMock.playerPositions(player1.address);
    expect(initialPlayerPosition).to.equal(0);
  });
  
  it("should revert when player move to same position", async () => {
    await expect(
      treasureHuntMock.move(0, { value: ethers.utils.parseEther("0.1") })
    ).to.be.revertedWith("Move to adjacent position");
  });

  it("should revert when player move to non adjacent position", async () => {
    await treasureHuntMock.setPlayerPosition(player1.address, 0); // mock the player position
    await expect(
      treasureHuntMock.move(12, { value: ethers.utils.parseEther("0.1") })
    ).to.be.revertedWith("Move to adjacent position");
  });

  it("should allow a player to move to position 1 at start", async () => {
    await treasureHuntMock.connect(player1).move(1, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(1);
  });
  
  it("should allow a player to move to an adjacent positions", async () => {
    await treasureHuntMock.connect(player1).move(2, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(2);
  });

  it("should allow a player to move to adjacent position 0", async () => {
    await treasureHuntMock.setPlayerPosition(player1.address, 1);
    await treasureHuntMock.connect(player1).move(0, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(0);
  });

  it("should not move treasure position for non prime position or position not multiple of 5 for player move", async () => {
    await treasureHuntMock.setPlayerPosition(player1.address, 11); // mock the player position
    await treasureHuntMock.setTreasurePosition(18); // mock the treasure position
    await treasureHuntMock.connect(player1).move(12, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(12);
    expect(await treasureHuntMock.getTreasurePosition()).to.equal(18);
  });
  
  it("should move treasure to adjacent position when player moves to a position multiple of 5", async () => {
    await treasureHuntMock.setPlayerPosition(player1.address, 24); // mock the player position
    await treasureHuntMock.setTreasurePosition(18); // mock the treasure position
    await treasureHuntMock.connect(player1).move(25, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(25);

    const newTreasurePosition = await treasureHuntMock.getTreasurePosition();
    expect(await treasureHuntMock.isAdjacentPosition(18, newTreasurePosition)).to.equal(true);
  });

  it("should jump treasure to a random position when player moves to a prime position", async () => {
    await treasureHuntMock.setTreasurePosition(18); // mock the treasure position
    await treasureHuntMock.setPlayerPosition(player1.address, 10); // mock the player position
    await treasureHuntMock.connect(player1).move(11, { value: ethers.utils.parseEther("0.1") });
    expect(await treasureHuntMock.playerPositions(player1.address)).to.equal(11);
    expect(await treasureHuntMock.getTreasurePosition()).to.not.equal(18);
  });

  it("should reward the player when they find the treasure", async () => {
    await treasureHuntMock.setTreasurePosition(18); // mock the treasure position
    await treasureHuntMock.setPlayerPosition(player1.address, 17); // mock the player position
    expect(await treasureHuntMock.connect(player1).move(18, { value: ethers.utils.parseEther("0.1") }))
      .to.emit(treasureHuntMock, "Won")
      .withArgs(player1.address, anyValue);
  });
});