/* agree with the Collection Type in .sol file */
export interface Collection{
  id:number
  cName:string
  author:string
  detailHash:string
  imgHash:string
  dynasty:string
  genre:Category
}
export enum Category {
  jewelry,
  painting,
  pottery
}


/* 
struct MarketItem {
        uint256 itemId;
        address nftContractAdd;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        address payable owner;
        bool sold;
    }
 */

export interface MarketItem{
  itemId?:number,
  nftContractAdd:string,
  tokenId:number,
  price:number
}