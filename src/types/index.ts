/* agree with the Collection Type in .sol file */
export interface Collection {
  id: number
  cName: string
  author: string
  detailHash: string
  imgHash: string
  dynasty: string
  genre: Category
}
export enum Category {
  jewelry,
  painting,
  pottery
}

export enum ItemStatus {
  BuyNow,
  OnAuction,
  Sold,
  New
}

export interface MarketItem {
  itemId: string,
  nftContractAdd: string,
  tokenId: string,
  price?: string,
  info?: MetaItem,
  status: ItemStatus
}

export interface MetaItem {
  name: string,
  description: string,
  image: string
}

/* 
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
    } */
export interface Auction {
  amount:string,
  duration:string,
  firstBidTime:string,
  reservePrice:string,
  bidder:string,
  curator:string
}




