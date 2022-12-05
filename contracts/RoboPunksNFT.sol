// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RoboPunksNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 10000;

    uint256 publicPrice = 0.02 ether;
    uint256 whiteListPrice = 0.002 ether;
    string status;

    bool public publicMintOpen = false;
    bool public whiteListMintOpen = false;


    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("FuzzToken", "Fuzz") {
        
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function publicPriceSetter (uint256 _publicPrice) external onlyOwner {
     publicPrice = _publicPrice;
    }

    function whitelistPriceSetter (uint256 _presalePrice) external onlyOwner {
     whiteListPrice = _presalePrice;
    }

    function getPrice () public view returns (uint256)  {
     if(publicMintOpen == true){
         return publicPrice;
     }
     if(whiteListMintOpen == true){
         return whiteListPrice;
     }
     return 0;
    }



    function unpause() public onlyOwner {
        _unpause();
    }

    // Modify the mint Windows
    function editMintWindows(
        bool _publicMintOpen,
        bool _whiteListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        whiteListMintOpen = _whiteListMintOpen;
    }

    // require only the allowList people to mint
    // Add publicMint and whiteListMintOpen Variables
    function whiteListMint(uint256 _quantity) public payable {
        require(whiteListMintOpen, "Allowlist Mint Closed");
        require(allowList[msg.sender], "You are not on the allow list");
        require(msg.value == getPrice() * _quantity, "Not Enough Funds");
        internalMint(_quantity);
    }

    //Add Payment
    //Add limiting supply
    function publicMint(uint256 _quantity) public payable  {
        require(publicMintOpen, "Public Mint Closed");
        require(msg.value == getPrice() * _quantity, "Not Enough Funds");
        internalMint(_quantity);
    }

    function internalMint(uint256 _quantity) internal {
        require(totalSupply() *_quantity <= maxSupply, "We Sold Out!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _address) external onlyOwner{
        // get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_address).transfer(balance);
    }

    // Popluate the Allow List
    function setAllowList(address[] calldata addresses) external onlyOwner{
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
