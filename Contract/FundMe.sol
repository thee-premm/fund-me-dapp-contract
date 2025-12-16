/*
 > fund (minimum boundary)
 > withdraw
 > histroy
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./EthToUsdConverter.sol";


error NotOwner();


contract FundMe{

    using EthUSDLib for uint; 

    uint constant MinValue = 5 * 1e18; // constant min value 

    address[] public arr; // array for the address

    mapping(address => uint) public AddressToFund; // mapping 

    // fund fn
    function fund() public payable {
        require(msg.value.getConvertionRate() >= MinValue, "MinBalceRequired");

        if(AddressToFund[msg.sender] == 0){
            arr.push(msg.sender); // only pushing new users
        }

        AddressToFund[msg.sender] += msg.value;
    }

    // owner address
    address immutable public i_Owner;
    constructor() {
        i_Owner = msg.sender; 
    }

    // modifier for withdraw
    modifier IsOwner {
        if (msg.sender != i_Owner) revert NotOwner();
        _;

    }

    // withdraw fn
    function Withdraw() public IsOwner(){

        // should follow CEI, for reentery vulnerability 

         // reverting the array ans mapping
         for(uint i=0; i<arr.length; i++)
            AddressToFund[arr[i]] = 0;

         delete arr;

        // call
         (bool isSuccess, )= payable(msg.sender).call{value : address(this).balance}("");
         require(isSuccess, "Call failed");

    }

    
    // special fallback functions)
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}