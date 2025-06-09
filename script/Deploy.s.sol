// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {StakingToken} from "../src/StakingToken.sol";
import {StakingContract} from "../src/StakingContract.sol";

/**
 * @title Deploy
 * @dev Deployment script for the StakingToken and StakingContract
 * This script handles the deployment of both contracts and logs their addresses
 */
contract Deploy is Script {
    /**
     * @dev Empty setup function as no setup is required for deployment
     */
    function setUp() public {}

    /**
     * @dev Main deployment function
     * Deploys both StakingToken and StakingContract
     * Logs the deployed contract addresses
     * @notice This function should be called with the appropriate network configuration
     */
    function run() public {
        vm.startBroadcast();
        // Deploy the staking token
        StakingToken token = new StakingToken();
        // Deploy the staking contract with the token address
        StakingContract staking = new StakingContract(address(token));
        vm.stopBroadcast();
        // Log the addresses
        console.log("StakingToken deployed at:", address(token));
        console.log("StakingContract deployed at:", address(staking));
    }
}
