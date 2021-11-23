import { contract,digitalMuseum } from './index'
import Web3 from 'web3'

/* Read Data */
async function getNumber(): Promise<number> {
    let result = 0
    await contract.methods.getData().call().then((val: number) => {
        result = val
    })
    console.log(result);
    
    return result
}
/* Write Data */
async function setNumber(number: number) {
    await contract.methods.setData(number).send({ from: digitalMuseum.from })
}

/* Read Brand */
async function getBrand(): Promise<string> {
    let result = ''
    await contract.methods.getBrand().call().then((val: string) => {
        console.log(result);
        result = val
    })
    return result
}

/* Write brand */
async function setBrand(newBrand: string) {
    await contract.methods.setBrand(newBrand).send({ from: digitalMuseum.from })
}

export {
    getNumber,
    setNumber,
    getBrand,
    setBrand
}