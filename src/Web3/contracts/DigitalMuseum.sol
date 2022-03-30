// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DigitalMuseum is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;

    /* details of the collection */
    struct Info {
        uint256 id;
        string cName;
        string author;
        string detailHash;
        string imgHash;
        string dynasty;
        Category genre;
        address curator;
    }
    struct Collection {
        Info info;
        string metaURL;
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
        Category _class,
        string memory _metaURL
    ) public nonReentrant isCurator {
        uint256 class = uint256(_class);
        require(class >= 0 || class <= 2, "invalid class parameter");
        _collectionIds.increment();
        uint256 _id = _collectionIds.current();
        Info memory info = Info(_id,
            _name,
            _author,
            _detailhash,
            _imghash,
            _dynasty,
            _class,
            curator
        );
        Collection memory newCollection = Collection(
            info,
            _metaURL
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
            if (idToCollection[i].info.id == _collectionId) {
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
            if (idToCollection[i].info.curator != address(0)) {
                listLength += 1;
            }
        }

        Collection[] memory list = new Collection[](listLength);
        for (uint256 i = 1; i <= totalCollection; i++) {
            /* if the collection exsits, push it to the array */
            if (idToCollection[i].info.curator != address(0)) {
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
        returns (Info memory)
    {
        Info memory info =  idToCollection[_collectionId].info;
        return info;
    }

     function fetchColletionMeta(uint256 _collectionId)
        public
        view
        returns (string memory)
    {
        string memory meta =  idToCollection[_collectionId].metaURL;
        return meta;
    }
}
