// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract escrowRBAC is AccessControl {
  bytes32 public constant BUYER_ROLE = keccak256("BUYER_ROLE");
  bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");

  enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

  State public currState;

  address public buyer;
  address payable public seller;


  constructor(address _buyer, address payable _seller) public {
    _setupRole(BUYER_ROLE, _buyer);
    _setupRole(SELLER_ROLE, _seller);
  }

  function deposit() external payable {
    require(hasRole(BUYER_ROLE, msg.sender), "Caller is not a buyer");
    require(currState == State.AWAITING_PAYMENT, "Already paid");
    currState = State.AWAITING_DELIVERY;
  }

  function confirmDelivery() external {
    require(hasRole(BUYER_ROLE, msg.sender), "Caller is not a buyer");
    require(currState == State.AWAITING_DELIVERY, "Cannot confirm delivery");

    currState = State.COMPLETE;
  }

  function withdrawPayment() external{
    require(hasRole(SELLER_ROLE, msg.sender), "Caller is not a seller");
    require(currState == State.COMPLETE, "Cannot confirm item has been received");
    seller.transfer(address(this).balance);
  }
}