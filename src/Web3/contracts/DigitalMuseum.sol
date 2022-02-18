// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DigitalMuseum is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;

    /* details of the collection */
    struct Collection {
        uint256 id;
        string cName;
        string author;
        string detailHash;
        string imgHash;
        string dynasty;
        Category genre;
        address curator;
    }
    enum Category {
        jewelry,
        painting,
        pottery
    }
    /* The curator */
    address public curator;
    mapping(uint256 => Collection) private idToCollection;
    mapping(address => Collection[]) private favorList;

    constructor() {
        curator = msg.sender;
    }

    /* Reverts if the transaction is not sent by the curator */
    modifier isCurator() {
        // The auction exists if the curator is not null.
        require(msg.sender == curator, "You are not the curator");
        _;
    }

    /* only museum can call this function */
    function createCollection(
        string memory _name,
        string memory _author,
        string memory _detailhash,
        string memory _imghash,
        string memory _dynasty,
        Category _class
    ) public nonReentrant isCurator {
        uint256 class = uint256(_class);
        require(class >= 0 || class <= 2, "invalid class parameter");
        _collectionIds.increment();
        uint256 _id = _collectionIds.current();
        Collection memory newCollection = Collection(
            _id,
            _name,
            _author,
            _detailhash,
            _imghash,
            _dynasty,
            _class,
            curator
        );
        idToCollection[_id] = newCollection;
    }

    function removeCollection(uint256 _collectionId)
        public
        isCurator
        nonReentrant
    {
        uint256 totalCollection = _collectionIds.current();
        for (uint256 i = 1; i <= totalCollection; i++) {
            if (idToCollection[i].id == _collectionId) {
                delete idToCollection[i];
            }
        }
    }

    function getCollections() public view returns (Collection[] memory) {
        uint256 totalCollection = _collectionIds.current();
        uint256 currenIndex = 0;
        uint256 listLength = 0;

        for (uint256 i = 1; i <= totalCollection; i++) {
            /* Gets the total of the exsiting collection */
            if (idToCollection[i].curator != address(0)) {
                listLength += 1;
            }
        }

        Collection[] memory list = new Collection[](listLength);
        for (uint256 i = 1; i <= totalCollection; i++) {
            /* if the collection exsits, push it to the array */
            if (idToCollection[i].curator != address(0)) {
                Collection storage currentItem = idToCollection[i];
                list[currenIndex] = currentItem;
                currenIndex += 1;
            }
        }
        return list;
    }

    function fetchColletionDetail(uint256 _collectionId)
        public
        view
        returns (Collection memory)
    {
        return idToCollection[_collectionId];
    }

    /* add collection to favorite list */
    // function toggleFavor(uint256 _collectionId) public nonReentrant {
    //     /* If the collection is not favored */
    //     if (favorList[msg.sender][_collectionId].curator == address(0)) {
    //         favorList[msg.sender].push(idToCollection[_collectionId]);
    //     } else {
    //         for (uint256 i = 0; i < favorList[msg.sender].length; i++) {
    //             if (favorList[msg.sender][i].id == _collectionId)
    //                 delete favorList[msg.sender][_collectionId];
    //         }
    //     }
    // }

    // function getFavorList() public view returns (Collection[] memory) {
    //     return favorList[msg.sender];
    // }
}
