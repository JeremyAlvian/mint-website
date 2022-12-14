// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract FuzzNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    uint256 SALES_MAX_QTY = 100;
    uint256 public constant MAX_QTY_PER_MINTER = 2;
    uint256 public PRE_SALES_PRICE; //5000000000000000
    uint256 public PUBLIC_SALES_PRICE;//10000000000000000
    uint256 public CREATOR_PRICE; 
    mapping(address => uint256) public publicMintedAmount;
    mapping(address => uint256) public whitelistMintedAmount;
    mapping(address => bool) public reservedClaimed;
    bytes32 whitelistMerkleRoot;
    bytes32 reservedMerkleRoot;
    uint256 totalSupply = 0;

    string public status; // PreSale | PublicSale | ReservedSale

    Counters.Counter private _tokenIdCounter;


    constructor() ERC721("Fuzz Token", "Fuzz") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmYmW93hPDSB28C3XjeuSeuWdXqQyPa9u6fvhgvkbP2Pt3/";
    }

    //function _startTokenId() internal pure override returns (uint256) {
    //    return 1;
    //}

    function presaleMint (bytes32[] memory proof, uint qty, uint allowance) public payable {
        require(keccak256(bytes(status)) == keccak256(bytes("PreSale")), "Presale period is over");
        require(MerkleProof.verify(proof, whitelistMerkleRoot, keccak256(abi.encodePacked(msg.sender ,allowance))), "You are not on the whitelist.");
        require(totalSupply + qty <= SALES_MAX_QTY, "Minting exceed the presale allocation.");
        require(whitelistMintedAmount[msg.sender] + qty <= allowance, "Max allowance exceeded.");
        require(getPrice() * qty == msg.value, "insufficient balance");
        // _safeMint(msg.sender, qty);
        for(uint256 i = 0; i < qty; i ++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            totalSupply++;
        }

        whitelistMintedAmount[msg.sender] += qty;
    }

    function publicMint(uint256 qty) public payable {
        require(keccak256(bytes(status)) == keccak256(bytes("PublicSale")), "Its currently not open for public");
        require(getPrice() > 0, "Item is not available");
        require(publicMintedAmount[msg.sender] + qty <= MAX_QTY_PER_MINTER,"Minting amount exceeds allowance per wallet");
        require(totalSupply + qty < SALES_MAX_QTY, "Minting exceed the sale allocation.");
        require(msg.value == getPrice() * qty, "insufficient balance");
        // _safeMint(msg.sender, qty);
        for(uint256 i = 0; i < qty; i ++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            totalSupply++;
        }

        publicMintedAmount[msg.sender] += qty;
    }

     function creatorMint() external payable onlyOwner{
        uint qty = SALES_MAX_QTY - totalSupply;
        require(keccak256(bytes(status)) == keccak256(bytes("PublicSale")), "Creator can only mint during Public Sale period");
        require(CREATOR_PRICE > 0, "Set the price first!");
        require(msg.value == CREATOR_PRICE * qty, "insufficient balance");
         for(uint256 i = 0; i < qty; i ++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            totalSupply++;
        }
    }

    function reservedMint(bytes32[] memory proof) public payable {
        require(keccak256(bytes(status)) == keccak256(bytes("ReservedSale")), "Reserved sale period is over");
        require(MerkleProof.verify(proof, reservedMerkleRoot, keccak256(abi.encodePacked(msg.sender))), "You are not on the reserved list.");
        require(totalSupply + 1 <= SALES_MAX_QTY, "Minting exceed the sale allocation.");
        require(!reservedClaimed[msg.sender], "You have claimed the reserved mint");
        reservedClaimed[msg.sender] = true;
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        totalSupply++;

    }

   

    function getPrice() public view returns (uint256) {
       if (keccak256(bytes(status)) == keccak256(bytes("PreSale"))) {
          return PRE_SALES_PRICE;
        } if(keccak256(bytes(status)) == keccak256(bytes("PublicSale"))) {
            return PUBLIC_SALES_PRICE;
        }
        return 0;
    }

    //owneronly functions, for withdraw and setters
    function withdraw() public onlyOwner nonReentrant {
        require(address(this).balance > 0, "no ether found");
        payable(owner()).transfer(address(this).balance);
    }

    function setPreSalePrice (uint256 _price) external onlyOwner {
        PRE_SALES_PRICE = _price;
    }

    function setPublicSalePrice (uint256 _price) external onlyOwner {
        PUBLIC_SALES_PRICE = _price;
    }

    function setCreatorPrice(uint256 _price) external onlyOwner{
        CREATOR_PRICE = _price;
    }

    function setStatus (string memory _status) external onlyOwner {
        status = _status;
    }

    function setWhitelistMerkleRoot (bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    function setReservedMerkleroot (bytes32 _reservedMerkleRoot) external onlyOwner {
        reservedMerkleRoot = _reservedMerkleRoot;
    }


    // The following functions are overrides required by Solidity.

    // function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    //     internal
    //     override(ERC721)
    // {
    //     super._beforeTokenTransfer(from, to, tokenId);
    // }

    // function supportsInterface(bytes4 interfaceId)
    //     public
    //     view
    //     override(ERC721)
    //     returns (bool)
    // {
    //     return super.supportsInterface(interfaceId);
    // }
}