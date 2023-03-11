// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";




contract AuctionV2 {

    enum AssetType { UNKNOWN, ERC721, ERC1155}
    // enum WayType { Seconds, Minute}

    mapping(address => mapping(uint256 => mapping(address => BidListing721))) private _bidlisting721s;

    mapping(address => uint256) public wallet;


    struct EnglishAutionSellList {
        address contractAddress;
        uint256 tokenId;
        uint256 startPrice;
        AssetType assetType;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }

    struct DutchAutionSellList {
        address contractAddress;
        uint256 tokenId;
        uint256 startPrice;
        uint256 lowestPrice;
        
        // WayType wayType;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }

    struct BidListing721 {
        uint256 highPrice;
        address currentBidder;
    }

    struct BidListing1155 {
        uint256 amount;
        uint256 highPrice;
        address currentBidder;
    }





    function englishAuctionERC721Bid(address _contractAddress,uint256 _tokenId, uint256 _price) public payable{
        address _owner = IERC721(_contractAddress).ownerOf(_tokenId);
        uint256 _highPrice = _bidlisting721s[_contractAddress][_tokenId][_owner].highPrice;
        require(_price == msg.value , "value insufficient");
        require(_price > _highPrice , "price error");
        _bidlisting721s[_contractAddress][_tokenId][_owner] = BidListing721({
            highPrice: _price,
            currentBidder: msg.sender
        });
        wallet[msg.sender] = _price;
    }


    function englishAuctionERC721Buy(address _contractAddress,uint256 _tokenId,EnglishAutionSellList calldata sellList,bytes calldata sellSig) public {
        address _owner = IERC721(_contractAddress).ownerOf(_tokenId);
        uint256 _endtime = sellList.endTime;

        // _verifyOrderSignature(sellList,sellSig); //卖方签名

        BidListing721 memory bidList =_bidlisting721s[_contractAddress][_tokenId][_owner];
        require(block.timestamp >= _endtime, "The end time is not reached");
        require(bidList.highPrice > sellList.startPrice);
        require(bidList.currentBidder == msg.sender , "Can't buy for others");

        if (sellList.assetType == AssetType.ERC721){
            IERC721(_contractAddress).safeTransferFrom(_owner, msg.sender, _tokenId);
        }
        // else if(sellList.assetType = AssetType.ERC1155){
        //     IERC1155(_contractAddress).safeTransferFrom(_owner, msg.sender, _tokenId,sellList.amount);
        // }


        //  _distributeFeeAndProfit(
        //         orderHash, //
        //         order.user, //seller
        //         IERC20(order.currencyAddress), //currencyaddress
        //         settle.price,
        //         order.fee
        //     );  //转账

    }



    function DutAuctionERC721Buy(address _contractAddress,uint256 _tokenId,DutchAutionSellList calldata sellList,bytes calldata sellSig) public payable{
        address _owner = IERC721(_contractAddress).ownerOf(_tokenId);
        uint256 _startTime = sellList.startTime;
        uint256 _endtime = sellList.endTime;

        // _verifyOrderSignature(sellList,sellSig); //卖方签名

        require(_startTime <= block.timestamp &&  
            block.timestamp<= _endtime, "time error");


        uint _timeElapsed = block.timestamp - _startTime;
        uint _discountRate = (sellList.startPrice - sellList.lowestPrice) / _timeElapsed ;
        uint discount = _discountRate * _timeElapsed;
        uint _price = sellList.startPrice - discount;


        if (_contractAddress == address(0)){

        require(msg.value >= _price, "value error");

        
        IERC721(_contractAddress).safeTransferFrom(_owner, msg.sender, _tokenId);
        
        // else if(sellList.assetType = AssetType.ERC1155){
        //     IERC1155(_contractAddress).safeTransferFrom(_owner, msg.sender, _tokenId,sellList.amount);
        // }

        uint refund = msg.value - _price;


        if(refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        }
        // else {
            //处理ERC20
        //     token.transferFrom(msg.sender,seller,sellerFee);  
        //     token.transferFrom(msg.sender,protocolFeeRecipient,calculatedProtocolFee);
        //     nft.transferFrom(seller,msg.sender,tokenid);
        // }


    

        //  _distributeFeeAndProfit(
        //         orderHash, //
        //         order.user, //seller
        //         IERC20(order.currencyAddress), //currencyaddress
        //         settle.price,
        //         order.fee
        //     );  //转账

    }


    function withDraw() external{
        payable(msg.sender).transfer(wallet[msg.sender]);
    }


}