pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	uint256 public constant tokensPerEth = 100;
	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

	function buyTokens() public payable {
		uint256 amountOfEth = msg.value;
		require(amountOfEth > 0, "Send ETH to buy tokens");
		uint256 amountOfTokens = amountOfEth * tokensPerEth;
		uint256 vendorBalance = yourToken.balanceOf(address(this));
		require(
			vendorBalance > amountOfTokens,
			"Vendor does not have sufficient tokens"
		);
		address buyer = msg.sender;
		bool sent = yourToken.transfer(buyer, amountOfTokens);
		require(sent, "Failed to transfer tokens");

		emit BuyTokens(buyer, amountOfEth, amountOfTokens);
	}

  function withdraw() public onlyOwner {
    uint256 vendorBalance = address(this).balance;
    (bool sent, ) = msg.sender.call{value: vendorBalance}("");
    require(sent, "Failed to withdraw funds");
  }

	function sellTokens(uint256 amount) public {
		require(amount > 0, "Input a number greater than 0 to sell");
		address user = msg.sender;
		uint256 userBalance = yourToken.balanceOf(user);
		require(userBalance >= amount, "You do not have enough tokens");
		uint256 amountOfEth = amount / tokensPerEth;
		uint256 vendorEthBalance = address(this).balance;
		require(vendorEthBalance >= amountOfEth, "Vendor does not have enough ETH");
		(bool sent) = yourToken.transferFrom(user, address(this), amount);
		require(sent, "Failed to transfer tokens");
		(bool ethSent, ) = user.call{value: amountOfEth }("");
		require(ethSent, "Failed to send ETH");

	}
}
