// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract MotorN is  Ownable, ERC721Enumerable{

 
    string public baseUri;
    uint256 public maxMotor;

    using Strings for uint256;


    bool public isSaleActive = true;

    mapping(address => uint256) public mintTotal;
    
    enum Operation {Call, DelegateCall}

    constructor()
        public
        ERC721("MotorN F", "MotorN F")
    {
        maxMotor = 5000;
    }

    function flipSaleState() public onlyOwner {
        isSaleActive = !isSaleActive;
    }


    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function tokenURI(uint256 tokenId) public view  override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = baseUri;
        return string(abi.encodePacked(baseURI, (tokenId.toString()),".txt"));
    }

    function _setBaseURI(string memory baseURI) internal {
        baseUri = baseURI;
    }
    

    function MotornAirdrop(address[] memory accounts) public onlyOwner {
        for (uint256 index = 0; index < accounts.length; index++) {
            uint256 mintIndex = totalSupply() + 10000;
            if (totalSupply() < maxMotor) {
            _safeMint(accounts[index], mintIndex);
            }
        }
    }
 
    function mintMotor() public  {
        require(isSaleActive, "Sale is not active");
        require(totalSupply() + 1 <= maxMotor, "Purchase would exceed max supply of Motor");
        require(mintTotal[msg.sender]  < uint8(1) ,"Exceeded times");

        mintTotal[msg.sender] = mintTotal[msg.sender] + 1;
        uint256 mintIndex = totalSupply() + 10000;
        _safeMint(msg.sender, mintIndex);
    }
    



    function execTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) public onlyOwner  payable returns (bool success) {
        if (operation == Operation.DelegateCall) {
            assembly {
                success := delegatecall(gas(), to, add(data, 0x20), mload(data), 0, 0)
            }
        } else {
            assembly {
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
            }
        }


    }

    }