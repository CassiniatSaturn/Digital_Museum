import { museumContract, digitalMuseum } from '@/Web3/web3/index'
import { Collection } from '@/types/index'
import { digitalmuseumaddress, marketaddress, nftaddress } from '@/Web3/contracts/config'
/* Read Collection List */
async function getCollections(): Promise<Collection[]> {
  const result: Collection[] = await museumContract.methods.getCollections().call()
  return result
}

/* Creates collection */
async function createCollection(cName:string,author:string,detailHash:string,imgHash:string,dynasty:string,type:number) {
  await museumContract.methods.createCollection(cName,author,detailHash,imgHash,dynasty,type).send({ from: digitalMuseum.from})
}

/* Removes collection */
async function removeCollection(collectionId:string){
  await museumContract.methods.removeCollection(collectionId).send({from:digitalMuseum.from})
}
/* Fetches the infomation of the collection */
async function fetchColletionDetail(collectionId:string,account:string):Promise<Collection>{
  const item = await museumContract.methods.fetchColletionDetail(collectionId).call({from:account})
  return item
}

/* Toggles the favor status of collection */
async function toggleFavor(collectionId:string,account:string) {
  await museumContract.methods.toggleFavor(collectionId).send({ from: account})
}

/* Reads favor list */
async function getFavorList(account:string):Promise<Array<Collection>> {
  let result:Array<Collection> = []
  result = await museumContract.methods.getFavorList().call({from:account})
  console.log(result);
  return result
}

export {
  getCollections,
  createCollection,
  fetchColletionDetail,
  toggleFavor,
  getFavorList,
  removeCollection
}