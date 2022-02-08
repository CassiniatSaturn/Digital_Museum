// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address contractAdd;

  constructor(address mktAdd) ERC721('Cassini','CAS'){
    /* allow the mkt to transfer nfts */
    contractAdd = mktAdd;
  }

  function forge(string memory tokenURI) public returns (uint){
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender,newItemId);
    _setTokenURI(newItemId,tokenURI);
    setApprovalForAll(contractAdd,true);
    return newItemId;
  }
}