// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyFactory {
    error DeploymentFailed();
    error InvalidAddress();
    error InvalidUnlockTime();
    error AlreadyWithdrawn();

    PiggyBank[] public allPiggyBanks;
    
    address public immutable developer;

    event PiggyBankCreated(address indexed piggyBank, address indexed owner, string purpose, uint256 unlockTime);

    constructor(address _developer) {
        if(_developer == address(0)) revert InvalidAddress();
        developer = _developer;
    }

    function createPiggyBank(
        string memory purpose, 
        uint256 unlockTime,
        bytes32 salt
    ) external returns (address) {
        if(unlockTime <= block.timestamp) revert InvalidUnlockTime();

        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(msg.sender, developer, purpose, unlockTime)
        );

        address newBank;
        assembly {
            newBank := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(newBank) {
                revert(0, 0)
            }
        }

        if(newBank == address(0)) revert DeploymentFailed();

        
        allPiggyBanks.push(PiggyBank(newBank));

        emit PiggyBankCreated(newBank, msg.sender, purpose, unlockTime);
        return newBank;
    }


    
    function getAllPiggyBanks() external view returns (PiggyBank[] memory) {
        return allPiggyBanks;
    }
} 