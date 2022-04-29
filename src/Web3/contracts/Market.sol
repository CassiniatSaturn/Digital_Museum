// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Market is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    /* 
        BuyNow: The item can be sold in a fixed price
        OnAuction: The item can be sold in auction
        Sold: The item has been sold
        New: Unsold
     */

    enum Status {
        BuyNow,
        OnAuction,
        Sold,
        New
    }

    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        address payable owner;
        Status status;
    }

    /* map the itemId to the Item */
    mapping(uint256 => MarketItem) private idToMktItem;

    /* Returns the detail of Item */
    function fetchMarketItemDetail(uint256 _itemId)
        public
        view
        returns (MarketItem memory)
    {
        return idToMktItem[_itemId];
    }

    /* Reverts if the transaction is not sent by the owner */
    modifier isOwner() {
        // The auction exists if the curator is not null.
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    /* Places an nft to the market */
    event MarketItemCreated(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        address indexed nftContract,
        address payable seller,
        address payable owner,
        Status status
    );

    function createMarketItem(address nftContract, uint256 tokenId)
        public
        payable
        nonReentrant
        isOwner
    {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMktItem[itemId] = MarketItem(
            itemId,
            tokenId,
            0,
            payable(msg.sender),
            payable(address(0)),
            Status.New
        );

        /* Transfers the nft from the creator to the contract */
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(
            itemId,
            tokenId,
            nftContract,
            payable(msg.sender),
            payable(address(0)),
            Status.New
        );
    }

    event MarketItemRemoved(uint256 indexed itemId, uint256 indexed tokenId);

    /* Remove Item from mkt */
    function removeItem(uint256 _itemId) public isOwner {
        /* if the item is on auction and the auction starts, it can't be removed*/
        if (idToMktItem[_itemId].status == Status.OnAuction) {
            require(
                auctions[_itemId].bidder == address(0),
                "The auction starts!"
            );
        }
        emit MarketItemRemoved(_itemId, idToMktItem[_itemId].tokenId);
        delete idToMktItem[_itemId];
    }

    /* Sets fixed price to sell */
    function setFixedPrice(uint256 _itemId, uint256 _price) public isOwner {
        require(idToMktItem[_itemId].status == Status.New);
        idToMktItem[_itemId].status = Status.BuyNow;
        idToMktItem[_itemId].price = _price;
    }

    /* Creates Auction */
    function createAuction(
        uint256 itemId,
        uint256 duration,
        uint256 reservePrice
    ) public payable nonReentrant auctionNonExistant(itemId) isOwner {
        require(idToMktItem[itemId].status == Status.New);
        idToMktItem[itemId].status = Status.OnAuction;
        // Initialize the auction details, including null values.
        auctions[itemId] = Auction({
            duration: duration,
            reservePrice: reservePrice,
            curator: owner,
            amount: 0,
            firstBidTime: 0,
            bidder: payable(address(0))
        });
        uint256 tokenId = idToMktItem[itemId].tokenId;
        // Emit an event describing the new auction.
        emit AuctionCreated(tokenId, duration, reservePrice);
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
            idToMktItem[itemId].status == Status.BuyNow,
            "Please submit the asking price in order to complete the purchase"
        );
        require(
            price == msg.value / (1 ether),
            "Please submit the asking price in order to complete the purchase"
        );

        idToMktItem[itemId].seller.transfer(msg.value);
        IERC721(contractAdd).transferFrom(address(this), msg.sender, tokenId);
        idToMktItem[itemId].owner = payable(msg.sender);
        idToMktItem[itemId].status = Status.Sold;
        _itemsSold.increment();
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 unsoldItemsCount = 0;
        uint256 currenIndex = 0;

        for (uint256 i = 1; i <= totalItems; i++) {
            /* if the item exsit */
            if (idToMktItem[i].seller != address(0)) {
                /* Only set the status in BUYNOW or ONAUCTION can be listed */
                if (
                    idToMktItem[i].status == Status.BuyNow ||
                    idToMktItem[i].status == Status.OnAuction
                ) {
                    unsoldItemsCount += 1;
                }
            }
        }

        MarketItem[] memory items = new MarketItem[](unsoldItemsCount);
        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].seller != address(0)) {
                if (
                    idToMktItem[i].status == Status.BuyNow ||
                    idToMktItem[i].status == Status.OnAuction
                ) {
                    MarketItem storage currentItem = idToMktItem[i];
                    items[currenIndex] = currentItem;
                    currenIndex = currenIndex + 1;
                }
            }
        }
        return items;
    }

    /* Returns items purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 currenIndex = 0;
        uint256 myItemsCount = 0;

        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].owner == msg.sender) {
                myItemsCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](myItemsCount);
        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].owner == msg.sender) {
                MarketItem storage currentItem = idToMktItem[i];
                items[currenIndex] = currentItem;
                currenIndex = currenIndex + 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated()
        public
        view
        isOwner
        returns (MarketItem[] memory)
    {
        uint256 totalItems = _itemIds.current();
        uint256 currenIndex = 0;
        uint256 createdItemsCount = 0;

        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].seller == msg.sender) {
                createdItemsCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](createdItemsCount);
        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMktItem[i].seller == msg.sender) {
                MarketItem storage currentItem = idToMktItem[i];
                items[currenIndex] = currentItem;
                currenIndex = currenIndex + 1;
            }
        }
        return items;
    }

    /* Auction */

    // Use OpenZeppelin's SafeMath library to prevent overflows.
    using SafeMath for uint256;

    // ============ Constants ============

    // The minimum amount of time left in an auction after a new bid is created; 15 min.
    uint16 public constant TIME_BUFFER = 60;
    // The ETH needed above the current bid for a new bid to be valid; 0.001 ETH.
    uint8 public constant MIN_BID_INCREMENT_PERCENT = 10;
    // Interface constant for ERC721, to check values in constructor.
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;

    // A mapping of all of the auctions currently running.
    mapping(uint256 => Auction) public auctions;

    // ============ Structs ============

    struct Auction {
        // The value of the current highest bid.
        uint256 amount;
        // The amount of time that the auction should run for,
        // after the first bid was made.
        uint256 duration;
        // The time of the first bid.
        uint256 firstBidTime;
        // The minimum price of the first bid.
        uint256 reservePrice;
        // The address of the current highest bid.
        address payable bidder;
        // The address of the auction's curator. The curator
        // can cancel the auction if it hasn't had a bid yet.
        address curator;
    }

    // ============ Events ============

    // All of the details of a new auction,
    // with an index created for the tokenId.
    event AuctionCreated(
        uint256 indexed tokenId,
        uint256 duration,
        uint256 reservePrice
    );

    // All of the details of a new bid,
    // with an index created for the tokenId.
    event AuctionBid(
        uint256 indexed tokenId,
        address indexed sender,
        uint256 value
    );

    // All of the details of an auction's cancelation,
    // with an index created for the tokenId.
    event AuctionCanceled(uint256 indexed tokenId);

    // All of the details of an auction's close,
    // with an index created for the tokenId.
    event AuctionEnded(
        uint256 indexed tokenId,
        address indexed winner,
        uint256 amount
    );

    // ============ Modifiers ============

    // Reverts if the auction does not exist.
    modifier auctionExists(uint256 itemId) {
        // The auction exists if the curator is not null.
        require(!auctionCuratorIsNull(itemId), "Auction doesn't exist");
        _;
    }

    // Reverts if the auction exists.
    modifier auctionNonExistant(uint256 itemId) {
        // The auction does not exist if the curator is null.
        require(auctionCuratorIsNull(itemId), "Auction already exists");
        _;
    }

    // Reverts if the auction is expired.
    modifier auctionNotExpired(uint256 itemId) {
        require(
            // Auction is not expired if there's never been a bid, or if the
            // current time is less than the time at which the auction ends.
            auctions[itemId].firstBidTime == 0 ||
                block.timestamp < auctionEnds(itemId),
            "Auction expired"
        );
        _;
    }

    // Reverts if the auction is not complete.
    // Auction is complete if there was a bid, and the time has run out.
    modifier auctionComplete(uint256 itemId) {
        require(
            // Auction is complete if there has been a bid, and the current time
            // is greater than the auction's end time.
            auctions[itemId].firstBidTime > 0 &&
                block.timestamp >= auctionEnds(itemId),
            "Auction hasn't completed"
        );
        _;
    }

    /* fetch the detail from auctions */
    function fetchAuction(uint256 itemId) public view returns (Auction memory) {
        return auctions[itemId];
    }

    // ============ Create Bid ============
    function createBid(uint256 itemId, uint256 amount)
        public
        payable
        nonReentrant
        auctionExists(itemId)
        auctionNotExpired(itemId)
    {
        // Validate that the user's expected bid value matches the ETH deposit.
        require(
            amount == msg.value / (1 ether),
            "Amount doesn't equal msg.value"
        );
        require(amount > 0, "Amount must be greater than 0");
        // Check if the current bid amount is 0.
        if (auctions[itemId].amount == 0) {
            // If so, it is the first bid.
            auctions[itemId].firstBidTime = block.timestamp;
            // We only need to check if the bid matches reserve bid for the first bid,
            // since future checks will need to be higher than any previous bid.
            require(
                amount >= auctions[itemId].reservePrice,
                "Must bid reservePrice or more"
            );
        } else {
            // Check that the new bid is sufficiently higher than the previous bid, by
            // the percentage defined as MIN_BID_INCREMENT_PERCENT.
            //convert ether to wei to avoid the demical
            uint256 parsedAmount = amount.mul(1 ether);
            uint256 parsedFormerAmount = auctions[itemId].amount.mul(1 ether);

            require(
                parsedAmount >=
                    parsedFormerAmount.add(
                        // Add 10% of the current bid to the current bid.
                        parsedFormerAmount.mul(MIN_BID_INCREMENT_PERCENT).div(
                            100
                        )
                    ),
                "Must bid more than last bid by MIN_BID_INCREMENT_PERCENT amount"
            );

            // Refund the previous bidder.
            bool result = attemptETHTransfer(
                auctions[itemId].bidder,
                parsedFormerAmount
            );
            require(result, "Fail to refund");
        }
        // Update the current auction.
        auctions[itemId].amount = amount;
        auctions[itemId].bidder = payable(msg.sender);
        // Compare the auction's end time with the current time plus the 15 minute extension,
        // to see whether we're near the auctions end and should extend the auction.
        if (auctionEnds(itemId) < block.timestamp.add(TIME_BUFFER)) {
            // We add onto the duration whenever time increment is required, so
            // that the auctionEnds at the current time plus the buffer.
            auctions[itemId].duration += TIME_BUFFER;
        }
        // Emit the event that a bid has been made.
        emit AuctionBid(itemId, msg.sender, amount);
    }

    // Sending ETH is not guaranteed complete, and the method used here will return false if
    // it fails. For example, a contract can block ETH transfer, or might use
    // an excessive amount of gas, thereby griefing a new bidder.
    // We should limit the gas used in transfers, and handle failure cases.
    function attemptETHTransfer(address to, uint256 value)
        private
        returns (bool)
    {
        // Here increase the gas limit a reasonable amount above the default, and try
        // to send ETH to the recipient.
        // NOTE: This might allow the recipient to attempt a limited reentrancy attack.
        (bool success, ) = to.call{value: value, gas: 30000}("");
        return success;
    }

    // ============ End Auction ============
    function endAuction(uint256 itemId, address nftContract)
        public
        payable
        nonReentrant
        auctionComplete(itemId)
    {
        require(auctions[itemId].amount != 0, "This item is not on auction");
        require(
            msg.sender == auctions[itemId].bidder || msg.sender == owner,
            "Only bidder or owner can end auction"
        );
        // Store relevant auction data in memory for the life of this function.
        address winner = auctions[itemId].bidder;
        uint256 amount = auctions[itemId].amount;
        // Remove all auction data for this token from storage.
        delete auctions[itemId];
        // We don't use safeTransferFrom, to prevent reverts at this point,
        // which would break the auction.
        uint256 tokenId = idToMktItem[itemId].tokenId;
        IERC721(nftContract).transferFrom(address(this), winner, tokenId);
        // Transfer the ETH to curator.
        uint256 parsedFormerAmount = auctions[itemId].amount.mul(1 ether);
        bool result = attemptETHTransfer(
            auctions[itemId].curator,
            parsedFormerAmount
        );
        require(result, "Fail to transfer");
        idToMktItem[itemId].owner = payable(winner);
        idToMktItem[itemId].status = Status.Sold;
        idToMktItem[itemId].price = amount;
        _itemsSold.increment();
        // Emit an event describing the end of the auction.
        emit AuctionEnded(itemId, winner, amount);
    }

    // ============ Cancel Auction ============

    function cancelAuction(uint256 _itemId)
        public
        nonReentrant
        isOwner
        auctionExists(_itemId)
    {
        // Check that there hasn't already been a bid for this NFT.
        require(
            uint256(auctions[_itemId].firstBidTime) == 0,
            "Auction already started"
        );
        // Remove all data about the auction.
        delete auctions[_itemId];
        // Switch the status of the item to NEW
        idToMktItem[_itemId].status = Status.New;
        // Emit an event describing that the auction has been canceled.
        emit AuctionCanceled(_itemId);
    }

    // Returns true if the auction's curator is set to the null address.
    function auctionCuratorIsNull(uint256 itemId) private view returns (bool) {
        // The auction does not exist if the curator is the null address,
        // since the NFT would not have been transferred in `createAuction`.
        return auctions[itemId].curator == address(0);
    }

    // Returns the timestamp at which an auction will finish.
    function auctionEnds(uint256 itemId) public view returns (uint256) {
        // Derived by adding the auction's duration to the time of the first bid.
        // NOTE: duration can be extended conditionally after each new bid is added.
        return auctions[itemId].firstBidTime.add(auctions[itemId].duration);
    }
}
