// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GasOptimizedSecureContract {
    address public immutable owner;
    uint256 public totalDeposits;
    mapping(address => uint256) private balances;
    uint256 private constant UNLOCKED = 1;
    uint256 private constant LOCKED = 2;
    uint256 private lockState = UNLOCKED;
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    error NotOwner();
    error InsufficientBalance();
    error ReentrantCall();
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    modifier nonReentrant() {
        if (lockState == LOCKED) revert ReentrantCall();
        lockState = LOCKED;
        _;
        lockState = UNLOCKED;
    }
    constructor() {
        owner = msg.sender;
    }
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount) external nonReentrant {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) revert InsufficientBalance();
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
    function emergencyWithdraw() external onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Emergency withdrawal failed");
    }
}
