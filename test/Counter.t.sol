// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
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

contract CounterTest is Test {
    StakePool public stakePool;
    StakeERC20 public stakingToken;
    RewardERC20 public rewardToken;
    
    address public owner;
    address public alice;
    address public bob;
    
    uint public constant INITIAL_BALANCE = 10000 * 10**18;
    uint public constant REWARD_RATE = 100;
    
    function setUp() public {
        // Setup accounts
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        
        stakingToken = new StakeERC20("Staking Token", "STK");
        rewardToken = new RewardERC20("Reward Token", "RWD");
        stakePool = new StakePool();
        
        stakingToken.transfer(alice, INITIAL_BALANCE);
        stakingToken.transfer(bob, INITIAL_BALANCE);
        
        rewardToken.transfer(address(stakePool), INITIAL_BALANCE * 10);
    }

    function test_CreatePool() public {
        uint poolId = stakePool.create_pool(
            address(stakingToken),
            address(rewardToken),
            REWARD_RATE
        );
        
        assertEq(poolId, 0, "Pool ID should be 0");
        
        StakePool.Pool memory pool = stakePool.retrieve_pool(poolId);
        assertEq(address(pool.token), address(stakingToken), "Wrong staking token");
        assertEq(address(pool.reward_token), address(rewardToken), "Wrong reward token");
        assertEq(pool.reward_rate, REWARD_RATE, "Wrong reward rate");
        assertTrue(pool.is_active, "Pool should be active");
    }

    function test_Stake() public {
    uint poolId = stakePool.create_pool(
        address(stakingToken),
        address(rewardToken),
        REWARD_RATE
    );
    
    uint stakeAmount = 1000 * 10**18;
    
    vm.startPrank(alice);
    stakingToken.approve(address(stakePool), stakeAmount);
    stakePool.stake(poolId, stakeAmount);
    vm.stopPrank();
    
    StakePool.Staker memory staker = stakePool.getStaker(poolId, alice);
    assertEq(staker.amount, stakeAmount, "Wrong stake amount");
    assertEq(staker.staker, alice, "Wrong staker address");
}
}