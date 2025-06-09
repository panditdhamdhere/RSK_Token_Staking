// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title StakingContract
 * @dev A staking contract that allows users to stake RIF tokens and earn rewards
 * The contract implements a reward rate system with configurable parameters
 * and includes safety features like reentrancy protection and pausable functionality
 */
contract StakingContract is Ownable, ReentrancyGuard, Pausable {
    // Token used for staking and rewards
    IERC20 public stakingToken;
    
    // Reward rate in basis points (100 = 10% APY)
    uint256 public rewardRate = 100;
    
    // Last time the reward was updated
    uint256 public lastUpdateTime;
    
    // Accumulated reward per token
    uint256 public rewardPerTokenStored;
    
    // Duration for which rewards are distributed
    uint256 public duration = 365 days;
    
    // Minimum amount required to stake (100 tokens)
    uint256 public minimumStake = 100 * 10**18;

    // Mapping of user's last reward per token paid
    mapping(address => uint256) public userRewardPerTokenPaid;
    
    // Mapping of user's earned rewards
    mapping(address => uint256) public rewards;
    
    // Mapping of user's staked balances
    mapping(address => uint256) public balances;
    
    // Total amount of tokens staked
    uint256 public totalSupply;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event DurationUpdated(uint256 newDuration);
    event MinimumStakeUpdated(uint256 newMinimumStake);

    /**
     * @dev Constructor that initializes the staking contract
     * @param _stakingToken Address of the token used for staking
     */
    constructor(address _stakingToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        lastUpdateTime = block.timestamp;
    }

    /**
     * @dev Modifier to update reward for a given account
     * @param account The account to update rewards for
     */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @dev Returns the last time rewards were applicable
     * @return The current block timestamp
     */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev Calculates the reward per token
     * @return The current reward per token
     */
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((lastTimeRewardApplicable() - lastUpdateTime) *
                rewardRate *
                1e18) / totalSupply);
    }

    /**
     * @dev Calculates the amount of rewards earned by an account
     * @param account The account to calculate rewards for
     * @return The amount of rewards earned
     */
    function earned(address account) public view returns (uint256) {
        return
            ((balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    /**
     * @dev Allows users to stake tokens
     * @param amount The amount of tokens to stake
     * @notice Requires approval from the user to transfer tokens
     * @notice Amount must be greater than or equal to minimumStake
     */
    function stake(
        uint256 amount
    ) external nonReentrant whenNotPaused updateReward(msg.sender) {
        require(amount >= minimumStake, "Below minimum stake");
        totalSupply += amount;
        balances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows users to withdraw staked tokens
     * @param amount The amount of tokens to withdraw
     * @notice Cannot withdraw more than staked balance
     */
    function withdraw(
        uint256 amount
    ) public nonReentrant whenNotPaused updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Allows users to claim their earned rewards
     * @notice Transfers all earned rewards to the caller
     */
    function getReward() public nonReentrant whenNotPaused updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /**
     * @dev Allows users to exit the staking contract
     * @notice Withdraws all staked tokens and claims all rewards
     */
    function exit() external whenNotPaused {
        withdraw(balances[msg.sender]);
        getReward();
    }

    /**
     * @dev Sets the reward rate
     * @param _rewardRate The new reward rate in basis points
     * @notice Only callable by the contract owner
     */
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    /**
     * @dev Sets the reward duration
     * @param _duration The new duration in seconds
     * @notice Only callable by the contract owner
     */
    function setDuration(uint256 _duration) external onlyOwner {
        duration = _duration;
        emit DurationUpdated(_duration);
    }

    /**
     * @dev Sets the minimum stake amount
     * @param _minimumStake The new minimum stake amount
     * @notice Only callable by the contract owner
     */
    function setMinimumStake(uint256 _minimumStake) external onlyOwner {
        minimumStake = _minimumStake;
        emit MinimumStakeUpdated(_minimumStake);
    }

    /**
     * @dev Pauses the contract
     * @notice Only callable by the contract owner
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract
     * @notice Only callable by the contract owner
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
