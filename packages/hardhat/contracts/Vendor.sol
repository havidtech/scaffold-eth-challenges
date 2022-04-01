pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable{
    uint amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    
  }
  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() public onlyOwner {
    payable(owner()).call{value: address(this).balance}("");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint amountOfTokens) public {
    uint amountOfEth =  amountOfTokens / tokensPerEth;

    // Transfer token 
    yourToken.transferFrom(msg.sender, address(this), amountOfTokens);

    // Transfer eth
    (bool response, bytes memory message) = payable(msg.sender).call{value: amountOfEth}("");
    if(!response){
      revert("CAN'T PAYOUT");
    }

    emit SellTokens(msg.sender, amountOfTokens, amountOfEth);

  }
}
