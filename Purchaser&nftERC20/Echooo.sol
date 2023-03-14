
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';


contract EchoooMarketplace is 
    ReentrancyGuard,
    Ownable,
    Pausable
{

    using SafeERC20 for IERC20;

    address public purchaser; //purchaser is  the official account of Echooo


    //For example, a bayc needs an azuki + 50 weth (if eth, use nativeAddress), The seller does not specify the tokenid corresponding to the nft contract
    struct Nft_ERC20 {
    address buyer;
    address seller;
    address sellNftAddress;   //Bayc contract Address
    address buyNftAddress;   // Azuki contract Address
    address targetErc20Address; // weth contract Address
    uint sellTokenId;   // assume Bayc tokenid is 1888
    uint buyTokenId;

    uint erc20Amount; // 50 * 10 **18
    uint256 side; //order type
    uint delegateType; //delegate type
    IDelegate executionDelegate;
    uint256 startTime;
    uint256 endTime;
    Fee[] fee;
    //signature
    bytes32 r;
    bytes32 s;
    uint8 v;
    Status status;

    }

     constructor(address _paymentReceiver, address _escrowAddress,address _purchaser, uint256 _paymentReceiverFee) {
        paymentReceiver = _paymentReceiver;
        escrowAddress = _escrowAddress;
        purchaser = _purchaser
        paymentReceiverFee = _paymentReceiverFee;
    }

    function changePurchaser(address newPurchaser) external onlyOwner {
        purchaser = newPurchaser;
    }



    function executeBuy(Input memory input) external payable nonReentrant whenNotPaused {
        require(_checkDeadlineAndCaller(input.settle.user, input.settle.deadline));
        _verifyInputSignature(input);

        for (uint256 i = 0; i < input.orders.length; i++) {
            _verifyOrderSignature(input.orders[i]);
        }
        uint256 amountPaid = msg.value;
        for(uint256 i=0; i < input.orders.length; i++){
            Order memory order = input.orders[i];

            if(Side(order.side) == Side.BUY){
                amountPaid -= _execute(order, input.settle);
            }else{ revert('unknown side');}
        }
        if (amountPaid > 0) {
            payable(msg.sender).transfer(amountPaid);
        }
    }



    function replacePurchase(Input memory input, address user) external payable nonReentrant whenNotPaused {
        require(purchaser == msg.sender, "no right to purchase instead");

        executeBuy(input);//First purchase the corresponding nft from the market to the purchaser

       for(uint256 i=0; i < input.orders[i].offerTokenAddress.length; i++){
            require(
                order.executionDelegate.executeSell(input.orders[i].offerTokenAddress[i], purchaser, user,input.orders[i].offerTokenIds[i],input.orders[i].amount,'OFFER'),
                'order delegation error'
            ); //purchaser is  the official account of Echooo,user is the user who enters the gold under the blockchain
           
        }

        //No fee
    }


    //This function is called by buyer
    function nftExchangeNftERC20(Nft_ERC20 calldata input, uint256 buyERC721TokenId) external payable nonReentrant whenNotPaused {
         _verifyInputSignature(input);
         //Verification time

         _verifyOrderSignature2(input.orders[i]);//Another way to verify the signature is to specify nft+erc20

         if(Side(order.side) == Side.BUY){
            
            IERC721(input.sellNftAddress).safeTransferFrom(seller, input.buyer, input.sellTokenId, _type); //The seller transfers nft to the buyer

            IERC721(input.buyNftAddress).safeTransferFrom(input.buyer, seller, buyERC721TokenId, _type);  //The buyer transfers nft to the seller

            input.targetErc20Address.safeTransferFrom(input.buyer,seller,erc20Amount); //The buyer transfers erc20 token to the seller
            }
        else{ revert('unknown side');}

            _distributeFeeAndProfit(
                orderHash, //
                order.user, //seller
                IERC20(order.currencyAddress), //currencyaddress
                order.price,
                order.tokenAddress,
                order.tokenId,
                order.fee
            );
        
    }


    //This function is called by seller
    function nftERC20ExchangeNft(Nft_ERC20 calldata input) external payable nonReentrant whenNotPaused {
         _verifyInputSignature(input);
         //Verification time

         _verifyOrderSignature2(input.orders[i]);

         if(Side(order.side) == Side.SELL){
            IERC721(input.sellNftAddress).safeTransferFrom(input.seller, input.buyer , input.sellTokenId, _type); //The seller transfers nft to the buyer

            IERC721(input.buyNftAddress).safeTransferFrom(input.buyer, input.seller, input.buyTokenId, _type);  //The buyer transfers nft to the seller

            input.targetErc20Address.safeTransferFrom(input.buyer,input.seller,erc20Amount); //The buyer transfers erc20 token to the seller
            }
        else{ revert('unknown side');}

            _distributeFeeAndProfit(
                orderHash, //
                order.user, //seller
                IERC20(order.currencyAddress), //currencyaddress
                order.price,
                order.tokenAddress,
                order.tokenId,
                order.fee
            );
        
    }




}