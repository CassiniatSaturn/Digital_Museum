import { nftContract, mktContract, digitalMuseum, web3 } from '@/Web3/web3/index'
import { MarketItem } from '@/types/index'
import { nftaddress } from '@/Web3/contracts/config'
import { getTokenURI } from './nftService'
import { fetchFromIpfs } from '../ipfsService'

/* Reads unsold items list */
async function fetchMarketItems(): Promise<MarketItem[]> {
  const result: Array<MarketItem> = await mktContract.methods.fetchMarketItems().call({ from: digitalMuseum.from })
  result.map(async (i) => {
    const uri = await getTokenURI(i.tokenId)
    console.log(uri);
    const metadata = await fetchFromIpfs(uri)
    console.log(JSON.parse(metadata as unknown as string));
    
  })
  console.log(result);
  return result
}

/* Get listing price */
async function getListingPrice(): Promise<string> {
  const listingPrice: Promise<string> = await mktContract.methods.getListingPrice().call({ from: digitalMuseum.from })
  return listingPrice
}

/* Creates items */
async function createMktItem(price: number, url: string) {
  const transaction1 = await nftContract.methods.forge(url).send({ from: digitalMuseum.from })
  const tokenID = transaction1.events.Transfer.returnValues.tokenId
  const parsedPrice = web3.utils.toBN(price)

  const listingPrice = await getListingPrice()
  const transaction2 = await mktContract.methods.createMarketItem(nftaddress, tokenID, parsedPrice).send({ from: digitalMuseum.from, value: listingPrice })
  console.log(transaction2);

  return tokenID
}

/* Reads items created by me */
async function fetchItemsCreated(): Promise<MarketItem[]> {
  const result: Array<MarketItem> = await mktContract.methods.fetchItemsCreated().call({ from: digitalMuseum.from })
  console.log(result);
  return result
}


/* Reads my items */
async function fetchMyNFTs(account: string): Promise<MarketItem[]> {
  const result: Array<MarketItem> = await mktContract.methods.fetchMyNFTs().call({ from: account })
  console.log(result);
  return result
}

/* uint256 itemId, address contractAdd */
async function createMarketSale(itemId: string, account: string, price: string) {
  const parsedPrice = web3.utils.toWei(price)
  const result: Array<MarketItem> = await mktContract.methods.createMarketSale(itemId, nftaddress).send({ from: account, value: parsedPrice })
  console.log(result);

}

export {
  fetchMarketItems,
  createMktItem,
  fetchItemsCreated,
  fetchMyNFTs,
  createMarketSale
}