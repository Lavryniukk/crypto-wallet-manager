// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract WalletManager {
	mapping(address=>uint) balances;
	
	event Withdrawal(address account, uint amount);
	event Deposit(address account, uint amount);	

	function withdraw(uint _amount) external {
		require(balances[msg.sender] >= _amount, "Not sufficient balance");
		balances[msg.sender] -= _amount;
		payable(msg.sender).transfer(_amount);
		emit Withdrawal(msg.sender, _amount);
	}

	function deposit() payable external {
		require(msg.value > 0, "Value has to be greater than zero");
		balances[msg.sender] += msg.value;
		emit Deposit(msg.sender, msg.value);
	}

	function getBalance() external view returns (uint){
		return balances[msg.sender];
	}
	
}
