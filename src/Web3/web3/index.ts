import Web3 from 'web3'
import DigitalMuseum from '../build/contracts/DigitalMuseum.json'
import { AbiItem } from 'web3-utils';
/* 实例化web3对象
链接到本地http协议的node */

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'));
// web3.eth.getAccounts().then(val => {
//   console.log(val);
// });
/* 启动浏览器中的metamask */
// web3 = new Web3(Web3.givenProvider)

/* 合约初始化 */

class DigitalMuseumWeb3 {
  address: string
  from: string

  constructor(address: string, from: string) {
    this.address = address
    this.from = from
  }
}

const address = '0x32C65fb1547C7accC95697E53558Ea611addb241'
const from = '0x874533B5573a8196C029CA69D1F12826cC695316'
const contract = new web3.eth.Contract(DigitalMuseum.abi as AbiItem[], address)
const digitalMuseum = new DigitalMuseumWeb3(address, from)
console.log(contract.methods);


export {
  web3,
  digitalMuseum,
  contract
}

