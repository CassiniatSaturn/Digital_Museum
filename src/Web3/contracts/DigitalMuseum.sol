// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DigitalMuseum {
    uint public data;
    string public brand;


    function setData(uint a) public {
        data = a;
    }
    
    function setBrand(string memory name) public{
        brand = name;
    }

    function getData() public view returns (uint) {
        return data;
    }
    
    function getBrand() public view returns (string memory) {
        return brand;
    }
}
