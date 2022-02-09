import Web3 from 'web3'
import DigitalMuseum from '../build/contracts/DigitalMuseum.json'
import Market from '../build/contracts/Market.json'
import NFT from '../build/contracts/NFT.json'
import { AbiItem } from 'web3-utils';
import { digitalmuseumaddress, marketaddress, nftaddress } from '../contracts/config'

/* Creates web3 service*/
let web3 = new Web3()
if ((window as any).ethereum) {
  web3 = new Web3((window as any).ethereum)
} else if ((window as any).web3) {
  web3 = new Web3(web3.currentProvider)
} else {
  alert('你需要先安装MetaMask')
}
(window as any).ethereum.enable()
console.log("web3 success")

/* Official museum account */
const from = '0x03E462A632c42593F42ba57738b642A2272Bc06C'

/* Interacting contracts */
class DigitalMuseumWeb3 {
  address: string
  from: string

  constructor(address: string, from: string) {
    this.address = address
    this.from = from
  }
}

const digitalMuseum = new DigitalMuseumWeb3(digitalmuseumaddress, from)
const museumContract = new web3.eth.Contract(DigitalMuseum.abi as AbiItem[], digitalmuseumaddress)
const nftContract = new web3.eth.Contract(NFT.abi as AbiItem[], nftaddress)
const mktContract = new web3.eth.Contract(Market.abi as AbiItem[], marketaddress)

export {
  web3,
  digitalMuseum,
  museumContract,
  nftContract,
  mktContract
}

