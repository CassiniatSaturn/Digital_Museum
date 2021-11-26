// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DigitalMuseum {
    /* details of the collection */
    struct Collection {
        uint256 id;
        string name;
        string author;
        string detailhash;
        string imghash;
        string dynasty;
        Category class;
    }
    enum Category {
        jewelry,
        painting,
        pottery
    }
    /* the museum that collection belongs to */
    address public museum;
    /* The array to store all the collections */
    Collection[] public collections;

    constructor(){
        museum = msg.sender;
    }

    function createCollection(string memory _name,string memory _author,string memory _detailhash, string memory _imghash,string memory _dynasty, Category _class) payable public {
        uint _id = collections.length;
        Collection memory newCollection = Collection(_id, _name, _author,_detailhash,_imghash,_dynasty,_class);
        collections.push(newCollection);
    }

    function getCollections() public view returns(Collection[] memory){
        return collections;
    }

    // function setBrand(string memory name) public {
    //     brand = name;
    // }
}
