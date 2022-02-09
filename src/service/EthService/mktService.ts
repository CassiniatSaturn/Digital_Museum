import { nftContract,mktContract } from '@/Web3/web3/index'
import { MarketItem } from '@/types/index'
import { marketaddress, nftaddress } from '@/Web3/contracts/config'
/* Reads Collection List */
async function getMktItems(): Promise<MarketItem[]> {
  const result: MarketItem[] = []
  // await museumContract.methods.getCollections().call().then((val: Collection[]) => {
  //   result = val
  // })
  // console.log(result);

  return result
}

/* Creates Collection */
async function createMktItem(price:number,url:string):Promise<number> {
  const tokenID = await nftContract.methods.forge(url)
/*  address contractAdd,
        uint256 tokenId,
        uint256 price */
  const mktCon = await mktContract.methods.createMarketItem(nftaddress,tokenID,price)
  console.log(tokenID,mktCon);
  
  return tokenID
}



export {
  getMktItems,
  createMktItem,
}