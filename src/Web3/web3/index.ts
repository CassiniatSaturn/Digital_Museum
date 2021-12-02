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

/* address of contract */
const address = '0x160A429C6E1954220615E244E094ce1B9d75605b'
/* accout */
const from = '0x03E462A632c42593F42ba57738b642A2272Bc06C'
const contract = new web3.eth.Contract(DigitalMuseum.abi as AbiItem[], address)
const digitalMuseum = new DigitalMuseumWeb3(address, from)

export {
  web3,
  digitalMuseum,
  contract
}

