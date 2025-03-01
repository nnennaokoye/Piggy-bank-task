// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    address public developer;
    address public owner;
    uint256 public unlockTime;
    string public purpose;
    bool private withdrawn;
    bool private closed;

    mapping(address => bool) public allowedTokens;

    error NotAuthorized();          
    error UnsupportedToken();       
    error InsufficientBalance();    
    error AlreadyWithdrawn();       
    error LockPeriodActive();       
    error InvalidWalletAddress();   
    error DepositsNotAllowed();     
    error ContractAlreadyClosed();  

    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawn(address indexed user, uint256 penaltyAmount);
    event PiggyBankClosed(address indexed user);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotAuthorized();
        _;
    }

    modifier isWithdrawn() {
        if (withdrawn) revert AlreadyClaimed();
        _;
    }

    modifier isNotClosed() {
        if (closed) revert ContractAlreadyClosed();
        _;
    }

    constructor(address _owner, string memory _purpose, uint256 _duration, address _developer) {
        if (_owner == address(0) || _developer == address(0)) revert InvalidWalletAddress();
        
        owner = _owner;
        purpose = _purpose;
        unlockTime = block.timestamp + _duration;
        developer = _developer;

        allowedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        allowedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
        allowedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI
    }

    function deposit(address token, uint256 amount) external onlyOwner isNotClosed {
        if (token == address(0)) revert InvalidWalletAddress();
        if (!allowedTokens[token]) revert UnsupportedToken();
        if (amount == 0) revert InsufficientBalance();
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, token, amount);
    }

    function withdraw(address token) external onlyOwner isWithdrawn isNotClosed {
        if (block.timestamp < unlockTime) revert LockPeriodActive();
        if (token == address(0)) revert InvalidWalletAddress();

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert InsufficientBalance();

        withdrawn = true;
        IERC20(token).transfer(owner, balance);
        emit Withdrawn(owner, balance);
    }

    function emergencyWithdraw(address token) external onlyOwner isWithdrawn isNotClosed {
        if (token == address(0) || developer == address(0)) revert InvalidWalletAddress();
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert InsufficientBalance();

        withdrawn = true;
        uint256 penalty = (balance * 15) / 100;
        uint256 remaining = balance - penalty;

        IERC20(token).transfer(developer, penalty);
        IERC20(token).transfer(owner, remaining);
        emit EmergencyWithdrawn(owner, penalty);
    }

    function closePiggyBank() external onlyOwner isNotClosed {
        closed = true;
        emit PiggyBankClosed(owner);
    }

    
    
}
