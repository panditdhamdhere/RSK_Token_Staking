// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {StakingContract} from "../src/StakingContract.sol";

/**
 * @title StakingTest
 * @dev Test suite for the StakingToken and StakingContract
 * Tests all major functionality including staking, rewards, withdrawals, and admin functions
 */
contract StakingTest is Test {
    // Contract instances
    StakingToken public stakingToken;
    StakingContract public stakingContract;

    // Test accounts
    address public alice = address(1);
    address public bob = address(2);
    address public owner = address(this);

    /**
     * @dev Sets up the test environment
     * Deploys new instances of StakingToken and StakingContract
     * Transfers initial tokens to test users
     * Funds the staking contract with tokens for rewards
     */
    function setUp() public {
        stakingToken = new StakingToken();
        stakingContract = new StakingContract(address(stakingToken));

        // Transfer some tokens to test users
        stakingToken.transfer(alice, 1000 * 10 ** 18);
        stakingToken.transfer(bob, 1000 * 10 ** 18);

        // Fund the staking contract with tokens for rewards
        stakingToken.mint(address(stakingContract), 1000000 * 10 ** 18);
    }

    /**
     * @dev Tests the basic staking functionality
     * Verifies that users can stake tokens and balances are updated correctly
     */
    function test_Stake() public {
        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 100 * 10 ** 18);
        stakingContract.stake(100 * 10 ** 18);
        assertEq(stakingContract.balances(alice), 100 * 10 ** 18);
        vm.stopPrank();
    }

    /**
     * @dev Tests staking below minimum amount
     * Verifies that the contract reverts when trying to stake less than minimum
     */
    function test_StakeBelowMinimum() public {
        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 50 * 10 ** 18);
        vm.expectRevert("Below minimum stake");
        stakingContract.stake(50 * 10 ** 18);
        vm.stopPrank();
    }

    /**
     * @dev Tests the withdrawal functionality
     * Verifies that users can withdraw staked tokens and balances are updated correctly
     */
    function test_Withdraw() public {
        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 100 * 10 ** 18);
        stakingContract.stake(100 * 10 ** 18);
        stakingContract.withdraw(50 * 10 ** 18);
        assertEq(stakingContract.balances(alice), 50 * 10 ** 18);
        vm.stopPrank();
    }

    /**
     * @dev Tests the reward calculation and claiming functionality
     * Verifies that rewards are calculated correctly over time
     * Checks that rewards can be claimed and balances are updated
     */
    function test_Rewards() public {
        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 100 * 10 ** 18);
        stakingContract.stake(100 * 10 ** 18);

        // Fast forward 1 year
        vm.warp(block.timestamp + 365 days);

        uint256 earned = stakingContract.earned(alice);
        assertGt(earned, 0);

        stakingContract.getReward();
        assertEq(stakingContract.earned(alice), 0);
        vm.stopPrank();
    }

    /**
     * @dev Tests the exit functionality
     * Verifies that users can exit the staking contract
     * Checks that all staked tokens and rewards are withdrawn
     */
    function test_Exit() public {
        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 100 * 10 ** 18);
        stakingContract.stake(100 * 10 ** 18);

        // Fast forward 1 year
        vm.warp(block.timestamp + 365 days);

        stakingContract.exit();
        assertEq(stakingContract.balances(alice), 0);
        assertEq(stakingContract.earned(alice), 0);
        vm.stopPrank();
    }

    /**
     * @dev Tests the pause functionality
     * Verifies that the contract can be paused and unpaused
     * Checks that staking is not possible when paused
     */
    function test_Pause() public {
        stakingContract.pause();
        assertTrue(stakingContract.paused());

        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 100 * 10 ** 18);
        vm.expectRevert(bytes4(keccak256("EnforcedPause()")));
        stakingContract.stake(100 * 10 ** 18);
        vm.stopPrank();

        stakingContract.unpause();
        assertFalse(stakingContract.paused());
    }

    /**
     * @dev Tests the minimum stake amount update functionality
     * Verifies that the minimum stake amount can be updated
     * Checks that staking below new minimum is not possible
     */
    function test_SetMinimumStake() public {
        uint256 newMinimum = 200 * 10 ** 18;
        stakingContract.setMinimumStake(newMinimum);
        assertEq(stakingContract.minimumStake(), newMinimum);

        vm.startPrank(alice);
        stakingToken.approve(address(stakingContract), 150 * 10 ** 18);
        vm.expectRevert("Below minimum stake");
        stakingContract.stake(150 * 10 ** 18);
        vm.stopPrank();
    }

    /**
     * @dev Tests the reward duration update functionality
     * Verifies that the reward duration can be updated
     */
    function test_SetDuration() public {
        uint256 newDuration = 180 days;
        stakingContract.setDuration(newDuration);
        assertEq(stakingContract.duration(), newDuration);
    }
}
