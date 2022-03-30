import { MarketItem, MetaItem } from "@/types";
import { getTokenURI } from "@/service/EthService/nftService";
import { baseURL } from "@/service/ipfsService";
import { fetchFromIpfs } from "@/service/ipfsService";

export async function converURLToMeta(itemsList: Array<MarketItem>) {
  const result = await Promise.all(itemsList.map(async (i) => {
    return (
      async () => {
        const uri = await getTokenURI(i.tokenId)
        console.log(uri, i.tokenId);

        /* Gets metadata from ipfs */
        const end = baseURL.length
        const hash = uri.substring(end + 1, uri.length + 1)
        const metadata: MetaItem = (await fetchFromIpfs(hash)).data
        const itemWithMeta = { ...i, info: metadata }
        return itemWithMeta
      })()
  }))
  return result
}