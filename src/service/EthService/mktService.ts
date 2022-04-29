import { nftContract, mktContract, digitalMuseum, web3 } from '@/Web3/web3/index'
import { Auction, BidHistory, MarketItem, MetaItem } from '@/types/index'
import { nftaddress } from '@/Web3/config'
import { converURLToMeta } from '@/utils/convertURLToMeta'

/* Reads unsold items list */
async function fetchMarketItems(account: string): Promise<MarketItem[]> {
  const itemsList: Array<MarketItem> = await mktContract.methods.fetchMarketItems().call({ from: account })
  const result = await converURLToMeta(itemsList)
  return result
}

/* Get listing price */
// async function getListingPrice(): Promise<string> {
//   const listingPrice: Promise<string> = await mktContract.methods.getListingPrice().call({ from: digitalMuseum.from })
//   return listingPrice
// }

/* Creates items */
async function createMktItem(url: string) {
  const transaction1 = await nftContract.methods.forge(url).send({ from: digitalMuseum.from })
  const tokenID = transaction1.events.Transfer.returnValues.tokenId
  console.log(tokenID);

  const transaction2 = await mktContract.methods.createMarketItem(nftaddress, tokenID).send({ from: digitalMuseum.from })
  return tokenID
}


/* Removes items */
async function removeMktItem(itemId: string) {
  await mktContract.methods.removeItem(itemId).send({ from: digitalMuseum.from })
}

/* Sell item in a fixed price */
async function setFixedPrice(itemId: string, price: number) {
  const parsedPrice = web3.utils.toBN(price)
  await mktContract.methods.setFixedPrice(itemId, parsedPrice).send({ from: digitalMuseum.from })
}

/* Sell item on auction */
async function createAuction(itemId: string, duration: number, reservePrice: number) {
  await mktContract.methods.createAuction(itemId, duration, reservePrice).send({ from: digitalMuseum.from })
}

/* Reads items created by me */
async function fetchItemsCreated(): Promise<MarketItem[]> {
  const itemsList: Array<MarketItem> = await mktContract.methods.fetchItemsCreated().call({ from: digitalMuseum.from })
  const result = await converURLToMeta(itemsList)
  console.log(result);

  return result
}

/* Reads my items */
async function fetchMyNFTs(account: string): Promise<MarketItem[]> {
  const itemsList: Array<MarketItem> = await mktContract.methods.fetchMyNFTs().call({ from: account })
  const result = await converURLToMeta(itemsList)
  return result
}

/* uint256 itemId, address contractAdd */
async function createMarketSale(itemId: string, account: string, price: string) {
  const parsedPrice = web3.utils.toWei(price)
  const result: Array<MarketItem> = await mktContract.methods.createMarketSale(itemId, nftaddress).send({ from: account, value: parsedPrice })
  console.log(result);

}

/* Creates bid */
async function createBid(itemId: string, amount: string, account: string) {
  const parsedPrice = web3.utils.toWei(amount)
  await mktContract.methods.createBid(itemId, amount).send({ from: account, value: parsedPrice })
}

async function endAuction(itemId: string, account: string) {
  await mktContract.methods.endAuction(itemId, nftaddress).send({ from: account })
}


async function cancelAuction(itemId: string) {
  await mktContract.methods.cancelAuction(itemId).send({ from: digitalMuseum.from })
}

async function auctionEnds(itemId: string, account: string): Promise<string> {
  const endsTime = await mktContract.methods.auctionEnds(itemId).call({ from: account })
  return endsTime
}

async function fetchMarketItemDetail(itemId: string, account: string): Promise<MarketItem> {
  const item: MarketItem = await mktContract.methods.fetchMarketItemDetail(itemId).call({ from: account })
  const result = await converURLToMeta([item])
  return result[0]
}


async function fetchAuction(itemId: string, account: string): Promise<Auction> {
  const result = await mktContract.methods.fetchAuction(itemId).call({ from: account })
  return result
}

async function verifyAuction(tokenId:number): Promise<BidHistory[]> {
  const list = await mktContract.getPastEvents('AuctionBid', {
    filter:{tokenId:tokenId},
    fromBlock: 0,
    toBlock: 'latest'
  }, (err, e) => {
    console.log(e);
  })
  const history = Promise.all(list.map(async i => {
    return (
      async () => {
        const { sender, tokenId, value } = i.returnValues
        const timestamp = (await web3.eth.getBlock(i.blockNumber)).timestamp
        const result: BidHistory = { timestamp: timestamp + '000', sender: sender, tokenId: tokenId, value: value }
        return result
      }
    )()
  }));
  return history
}

export {
  fetchMarketItems,
  createMktItem,
  fetchItemsCreated,
  removeMktItem,
  fetchMyNFTs,
  createMarketSale,
  createBid,
  endAuction,
  cancelAuction,
  setFixedPrice,
  createAuction,
  auctionEnds,
  fetchMarketItemDetail,
  fetchAuction,
  verifyAuction
}