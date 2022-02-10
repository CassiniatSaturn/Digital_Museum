// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Market is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    /* service fee */
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContractAdd;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        address payable owner;
        bool sold;
    }
    /* map the itemId to the Item */
    mapping(uint256 => MarketItem) private idToMktItem;

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Places an nft to the market */
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContractAdd,
        uint256 indexed tokenId,
        uint256 price,
        address payable seller,
        address payable owner,
        bool sold
    );

    function createMarketItem(
        address contractAdd,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price should be at least 1wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMktItem[itemId] = MarketItem(
            itemId,
            contractAdd,
            tokenId,
            price,
            payable(msg.sender),
            payable(address(0)),
            false
        );

        IERC721(contractAdd).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            contractAdd,
            tokenId,
            price,
            payable(msg.sender),
            payable(address(0)),
            false
        );
    }

    /* Creates the sale of a market item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId, address contractAdd)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMktItem[itemId].price;
        uint256 tokenId = idToMktItem[itemId].tokenId;
        require(
            price == msg.value/(1 ether),
            "Please submit the asking price in order to complete the purchase"
        );

        idToMktItem[itemId].seller.transfer(msg.value);
        IERC721(contractAdd).transferFrom(address(this), msg.sender, tokenId);
        idToMktItem[itemId].owner = payable(msg.sender);
        idToMktItem[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 unsoldItemsCount = _itemIds.current() - _itemsSold.current();
        uint256 currenIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemsCount);
        for (uint i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].owner == address(0)) {
                MarketItem storage currentItem = idToMktItem[i];
                items[currenIndex] = currentItem;
                currenIndex = currenIndex + 1;
            }
        }
        return items;
    }

    /* Returns onlyl items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 currenIndex = 0;
        uint256 myItemsCount = 0;

        for(uint i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].owner == msg.sender) {
                myItemsCount +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](myItemsCount);
        for (uint i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].owner == msg.sender) {
                MarketItem storage currentItem = idToMktItem[i];
                items[currenIndex] = currentItem;
                currenIndex = currenIndex + 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 currenIndex = 0;
        uint256 createdItemsCount = 0;

        for(uint i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].seller == msg.sender) {
                createdItemsCount +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](createdItemsCount);
        for (uint i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].seller == msg.sender) {
                MarketItem storage currentItem = idToMktItem[i];
                items[currenIndex] = currentItem;
                currenIndex = currenIndex + 1;
            }
        }
        return items;
    }

}
