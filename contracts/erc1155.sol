// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract MotorN is  Ownable, ERC1155{

 
    string public baseUri;
    uint256 public maxMotor;



    bool public isSaleActive = true;

    mapping(address => uint256) public mintTotal;
    
    enum Operation {Call, DelegateCall}

    constructor(string memory _url)
        public
        ERC1155(_url)
    {
        maxMotor = 5000;
    }

    function flipSaleState() public onlyOwner {
        isSaleActive = !isSaleActive;
    }

    }