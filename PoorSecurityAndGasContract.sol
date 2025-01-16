// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PoorSecurityAndGasContract {
    address public owner;
    uint256 public totalDeposits;
    mapping(address => uint256) public balances;
    event Deposit(address user, uint256 amount);
    event Withdrawal(address user, uint256 amount);
    constructor() {
        owner = msg.sender;
    }
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= amount;
        emit Withdrawal(msg.sender, amount);
    }
    function getAllDepositors() external view returns (address[] memory) {
        address[] memory depositors = new address[](totalDeposits);
        for (uint256 i = 0; i < totalDeposits; i++) {
            depositors[i] = address(uint160(i));
        }
        return depositors;
    }
    function emergencyWithdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 contractBalance = address(this).balance;
        (bool success, ) = msg.sender.call{value: contractBalance}("");
        require(success, "Emergency withdrawal failed");
    }
    fallback() external payable {}
}
