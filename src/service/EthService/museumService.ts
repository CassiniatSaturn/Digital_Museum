import { museumContract, digitalMuseum } from '@/Web3/web3/index'
import { Collection } from '@/types/index'
import { digitalmuseumaddress, marketaddress, nftaddress } from '@/Web3/contracts/config'
/* Read Collection List */
async function getCollections(): Promise<Collection[]> {
  let result: Collection[] = []
  await museumContract.methods.getCollections().call().then((val: Collection[]) => {
    result = val
  })
  console.log(result);

  return result
}

/* Create Collection */
async function createCollection(cName:string,author:string,detailHash:string,imgHash:string,dynasty:string,type:number) {
  await museumContract.methods.createCollection(cName,author,detailHash,imgHash,dynasty,type).send({ from: digitalMuseum.from})
}

/* add collection to favor list */
async function addToFavor(index:number) {
  await museumContract.methods.addToFavor(index).send({ from: digitalmuseumaddress})
}

/* get favor list */
async function getFavorList():Promise<Array<number>> {
  let result:Array<number> = []
  await museumContract.methods.getFavorList().call().then((list: Array<number>) => {
    result = list
  })
  console.log(result);
  return result
}

export {
  getCollections,
  createCollection,
}