// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "../src/StakePool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**18); // Mint 1M tokens
    }
}

contract RewardERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**18); // Mint 1M tokens
    }
}

contract StakePoolScript is Script {
    StakePool public stakePool;
    StakeERC20 public stakingToken;
    RewardERC20 public rewardToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        stakingToken = new StakeERC20("Staking Token", "STK");
        rewardToken = new RewardERC20("Reward Token", "RWD");
        
        stakePool = new StakePool();

        uint rewardRate = 100;
        uint poolId = stakePool.create_pool(
            address(stakingToken),
            address(rewardToken),
            rewardRate
        );

        rewardToken.transfer(address(stakePool), 100000 * 10**18);
        address testUser1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; 
        address testUser2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; 
        
        stakingToken.transfer(testUser1, 10000 * 10**18);
        stakingToken.transfer(testUser2, 10000 * 10**18);

        vm.stopBroadcast();

       
        console.log("Deployments:");
        console.log("StakePool deployed to:", address(stakePool));
        console.log("Staking Token deployed to:", address(stakingToken));
        console.log("Reward Token deployed to:", address(rewardToken));
        console.log("Pool ID:", poolId);
    }
}