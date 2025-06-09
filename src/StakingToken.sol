// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakingToken
 * @dev ERC20 token contract for the Rootstock Infrastructure Token (RIF)
 * This token is used for staking in the StakingContract
 */
contract StakingToken is ERC20, Ownable {
    /**
     * @dev Constructor that initializes the token with name "Rootstock Infra Token" and symbol "RIF"
     * Mints initial supply of 1,000,000 tokens to the contract deployer
     */
    constructor() ERC20("Rootstock Infra Token", "RIF") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @dev Mints new tokens to a specified address
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     * @notice Only the contract owner can call this function
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
