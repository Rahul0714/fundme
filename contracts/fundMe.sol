// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from './priceConverter.sol';

contract FundMe {
    using PriceConverter for uint256;
    uint public constant MINUSD = 5e18;
    address[] public funders;
    mapping (address funder => uint amountFunded) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINUSD, "Not enough Money Sent!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint index=0;index<funders.length;index++) {
            address funder = funders[index];
            addressToAmountFunded[funder] =0;  // if you do it this way then the value will be set to 0 so need to check again
        }
        funders = new address[](0);
        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Something went wrong");
    }
    modifier onlyOwner() {
        require(msg.sender == i_owner, "Must be the Owner!");
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}