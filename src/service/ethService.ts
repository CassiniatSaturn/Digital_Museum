import { contract, digitalMuseum } from '@/Web3/web3/index'
import { Collection } from '@/types/index'
/* Read Collection List */
async function getCollections(): Promise<Collection[]> {
  let result: Collection[] = []
  await contract.methods.getCollections().call().then((val: Collection[]) => {
    result = val
  })
  console.log(result);

  return result
}

/* Create Collection */
async function createCollection(cName:string,author:string,detailHash:string,imgHash:string,dynasty:string,type:number) {
  await contract.methods.createCollection(cName,author,detailHash,imgHash,dynasty,type).send({ from: digitalMuseum.from,gas:6000000 })
}

/* add collection to favor list */
async function addToFavor(index:number) {
  await contract.methods.addToFavor(index).send({ from: digitalMuseum.from,gas:6000000 })
}

/* get favor list */
async function getFavorList():Promise<Array<number>> {
  let result:Array<number> = []
  await contract.methods.getFavorList().call().then((list: Array<number>) => {
    result = list
  })
  console.log(result);
  return result
}

export {
  getCollections,
  createCollection,
}