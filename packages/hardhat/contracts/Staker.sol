// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  mapping ( address => uint256 ) public balances;
  uint256 public deadline = block.timestamp + 72 hours;
  uint256 public constant threshold = 1 ether;
  bool public openForWithdraw = false;

  event Stake(address,uint256);
  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    require(msg.value > 0, "NOT ENOUGH!");
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    require(timeLeft() == 0, "NOT YET TIME");
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }else{   // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      openForWithdraw = true;
    }
  }

  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public notCompleted {
    require(openForWithdraw, "NOT YET TIME");
    uint balance = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool response, ) = payable(msg.sender).call{value: balance}("");
    if(!response){
      revert("PROBLEM WITHDRAWING");
    }
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline){
      return 0;
    }
    return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), "NOT ALLOWED");
    _;
  }

}
