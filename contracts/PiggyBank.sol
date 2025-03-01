// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {
    
    address public immutable accountHolder;
    address public immutable feeCollector;
    string public savingsPurpose;
    uint256 public maturityDate;
    bool public withdrawn;

    mapping(address => bool) public supportedTokens;

    error UnauthorizedAccess();          
    error UnsupportedTokenType();       
    error InvalidTokenAmount();    
    error FundsAlreadyWithdrawn();       
    error MaturityDateNotReached();       
    error InvalidTokenAddress();   

    event TokensDeposited(address indexed user, address indexed token, uint256 amount);
    event SavingsWithdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawal(address indexed user, uint256 penaltyAmount, uint256 receivedAmount);

    modifier onlyAccountHolder() {
        if (msg.sender != accountHolder) revert UnauthorizedAccess();
        _;
    }

    modifier savingsActive() {
        if (withdrawn) revert FundsAlreadyWithdrawn();
        _;
    }

    constructor(
        address _accountHolder,
        address _feeCollector,
        string memory _purpose,
        uint256 _maturityDate
    ) {
        if (_accountHolder == address(0) || _feeCollector == address(0)) revert InvalidTokenAddress();
        
        accountHolder = _accountHolder;
        feeCollector = _feeCollector;
        savingsPurpose = _purpose;
        maturityDate = _maturityDate;
    }

    function setAllowedTokens(address[] memory tokens) external onlyAccountHolder {
        for (uint256 i = 0; i < tokens.length; i++) {
            supportedTokens[tokens[i]] = true;
        }
    }

    function deposit(address token, uint256 amount) external onlyAccountHolder savingsActive {
        if (token == address(0)) revert InvalidTokenAddress();
        if (!supportedTokens[token]) revert UnsupportedTokenType();
        if (amount == 0) revert InvalidTokenAmount();
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit TokensDeposited(msg.sender, token, amount);
    }

    function withdraw(address token) external onlyAccountHolder savingsActive {
        if (block.timestamp < maturityDate) revert MaturityDateNotReached();
        if (token == address(0)) revert InvalidTokenAddress();

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert InvalidTokenAmount();

        withdrawn = true;
        IERC20(token).transfer(accountHolder, balance);
        emit SavingsWithdrawn(accountHolder, balance);
    }

    function emergencyWithdraw(address token) external onlyAccountHolder savingsActive {
        if (token == address(0)) revert InvalidTokenAddress();
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert InvalidTokenAmount();

        withdrawn = true;
        uint256 penalty = (balance * 15) / 100;
        uint256 remaining = balance - penalty;

        IERC20(token).transfer(feeCollector, penalty);
        IERC20(token).transfer(accountHolder, remaining);
        emit EmergencyWithdrawal(accountHolder, penalty, remaining);
    }
}