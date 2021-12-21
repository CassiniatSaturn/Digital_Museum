// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DigitalMuseum {
    /* details of the collection */
    struct Collection {
        uint256 id;
        string cName;
        string author;
        string detailHash;
        string imgHash;
        string dynasty;
        Category genre;
    }
    enum Category {
        jewelry,
        painting,
        pottery
    }
    /* the museum that collection belongs to */
    address public museum;
    /* The array to store all the collections */
    Collection[] private collections;
    /* log the left gas */
    event checkGas(
        uint gasLimit,
        uint256 gasLeft
    );
    address[] private collectionList;
    mapping(address=>uint[]) private favorList;

    constructor(){
    /* only official account is allowed to create collections */
        museum = msg.sender;
    }

    /* only museum can call this function */
    function createCollection(string memory _name,string memory _author,string memory _detailhash, string memory _imghash,string memory _dynasty, Category _class) payable public returns(bytes32) {
       require(
            msg.sender == museum,
            "Only museum can create new collection."
        );
        uint class = uint(_class);
        require(
            class>=0||class<=2,
            "invalid class parameter"
        );
        uint _id = collections.length;
        Collection memory newCollection = Collection(_id, _name, _author,_detailhash,_imghash,_dynasty,_class);
        collections.push(newCollection);
        /* If the collection is created successfully, return the hash of this block */
        return blockhash(block.number);
    }

    function getCollections() public view returns(Collection[] memory){
        return collections;
    }

    /* add collection to favorite list */
    function addToFavor(uint index) payable public returns(uint[] memory){
        favorList[msg.sender].push(index);
        return favorList[payable(msg.sender)];
    }

    function getFavorList() public view returns(uint[] memory){
        return favorList[payable(msg.sender)];
    }

}
