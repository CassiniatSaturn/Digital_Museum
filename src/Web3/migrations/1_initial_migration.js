const fs = require('fs');

const DigitalMuseum = artifacts.require("DigitalMuseum");
const NFT = artifacts.require("NFT");
const Market = artifacts.require("Market");

module.exports = async function (deployer) {
  await deployer.deploy(DigitalMuseum);
  await deployer.deploy(Market)
  await deployer.deploy(NFT, Market.address);

  let config = `
  export const digitalmuseumaddress = "${DigitalMuseum.address}"
  export const marketaddress =  "${Market.address}"
  export const nftaddress = "${NFT.address}"
  `

  let data = JSON.stringify(config)
  fs.writeFileSync('config.ts', JSON.parse(data))
};
