// SPDX-License-Identifier:MIT
pragma solidity ^0.8.1;


import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract FC is ERC20, Ownable {
    using Address for address;
 

    event Withdraw(address user, uint256 amount);  


    receive() external payable {}  

    function withdraw() public onlyOwner {  
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(IERC20 token) public onlyOwner {  
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function burn(uint256 amount) public virtual { 
        super._burn(_msgSender(), amount);
    }   


    constructor() ERC20("FC", "FC") {   
        _mint(owner(), 60 *10**8 * 10**decimals());
    }

    function BatchTransfer(address[] memory accounts, uint256[] memory amounts)  
        public
        onlyOwner
    {
        require(accounts.length == amounts.length,"length is invalid");
        for (uint256 index = 0; index < accounts.length; index++) {
            super._transfer(address(this), accounts[index],amounts[index]);
        }
    }


}
