// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakePool is Ownable(msg.sender) {

    uint pool_count;
    
    struct Pool {
        uint id;
        IERC20 token;
        IERC20 reward_token;
        uint timestamp;
        bool is_active;
        uint reward_rate;
    }

    struct Staker {
        address staker;
        uint amount; 
    }

    mapping(uint => Pool) public pools;
    mapping(uint => mapping(address => Staker))  public staking;

    function create_pool(address _token, address _reward_token, uint _reward_rate) external onlyOwner returns (uint) {
        uint pool_id = pool_count++;
        pools[pool_id] = Pool({
            id: pool_id,
            token: IERC20(_token),
            reward_token: IERC20(_reward_token),
            timestamp: block.timestamp,
            is_active: true,
            reward_rate: _reward_rate
        });
        return pool_id;
    }

    function retrieve_pool(uint _id) external view returns (Pool memory){
        Pool memory pool = pools[_id];
        return Pool ({
            id: pool.id,
            token: pool.token,
            reward_token: pool.reward_token,
            timestamp: pool.timestamp,
            is_active: pool.is_active,
            reward_rate: pool.reward_rate
        });
    }

    function stake(uint _id, uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        Pool storage pool = pools[_id];
        require(pool.timestamp != 0, "Pool does not exist");
        require(pool.is_active, "Pool is not active");

        Staker storage staker = staking[_id][msg.sender];
        if (staker.staker == address(0)) {
            staker.staker = msg.sender;
        }
        staker.amount += _amount;


        require(pool.token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
    }

    function getStaker(uint _poolId, address _staker) external view returns (Staker memory) {
        return staking[_poolId][_staker];
    }




}
