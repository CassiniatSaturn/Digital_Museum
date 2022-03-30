import { nftContract, mktContract, digitalMuseum, web3 } from '@/Web3/web3/index'
import { MarketItem } from '@/types/index'

/* Gets tokenURI */
export async function getTokenURI(tokenID:string): Promise<string> {
  const url = await nftContract.methods.tokenURI(tokenID).call({ from: digitalMuseum.from})
  return url
}

