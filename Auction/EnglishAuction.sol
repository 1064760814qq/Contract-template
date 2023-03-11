// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";




contract AuctionV2 {

    enum AssetType { UNKNOWN, ERC721, ERC1155}

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


    function englishAuctionERC721Buy(address _contractAddress,uint256 _tokenId,EnglishAutionSellList memory sellList,bytes calldata sellerSig) public {
        address _owner = IERC721(_contractAddress).ownerOf(_tokenId);
        uint256 _endtime = sellList.endTime;

        // _verifyOrderSignature(sellList,sellerSig); //卖方签名

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

    function withDraw() external{
        payable(msg.sender).transfer(wallet[msg.sender]);
    }


}