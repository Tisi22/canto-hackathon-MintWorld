// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FirstMintmonUriStorage.sol";

contract FirstMintmon is ERC721, ERC721Enumerable, FirstMintmonUriStorage, Ownable {

    bool public mintState;
    uint256 tokenId;
    
    mapping(address => bool) firstMintmonMinted;

    constructor() ERC721("MyToken", "MTK") {
        mintState = false;
    }

    function safeMint(uint8 num) public returns (uint256) {
        require (mintState, "minting paused");
        require(!firstMintmonMinted[msg.sender], "already minted");
        require(num > 0, "Wrong arg num");
        require(num <= 4, "Wrong arg num");

        string memory name;
        string memory image;
        string memory tp;
        string memory description;

        firstMintmonMinted[msg.sender] = true;

        tokenId++;

        if(num == 1){
            name = "Firery"; 
            image = "https://ipfs.moralis.io:2053/ipfs/QmeZ1YX2dqz48AFT3mJs3gUPfpKEw3R1b7CiiivHnouUiU/Firefy" ;         
            tp = "Fire";
            description = "Firery; the small fire mintie. Its natural habitat are active volcanoes. Finding it can be difficult, however, it can be observed during volcano outbreaks. They are generally friendly creatures, but it is strongly advised against hugging them.";
        }
        else if (num == 2){
            name = "Stoney"; 
            image = "https://ipfs.moralis.io:2053/ipfs/QmXfNWapnxzCwddWKuJiJyTgkqQiHNzahfTNe3CKuzCgh7/Stoney" ;         
            tp = "Earth";
            description = "Stoney; the small rock mintie. Its natural habitat are the mountains. Finding it is a difficult task as it fits perfectly with normal stones. It's a peaceful creature, unless you're unlucky enough to step on it.";
        }
        else if( num == 3){
            name = "Watery"; 
            image = "https://ipfs.moralis.io:2053/ipfs/QmbmXEdu8Kb9Wikzwx1s7gJETJr9h6X6KjjMLvun4Ur1V2/Watery" ;         
            tp = "Water";
            description = "Watery; the small water mintie. Its natural habitat are rivers and lakes. Its playful nature is especially known by fishermen. For better or worse.";
        }
        else{
            name = "Windry"; 
            image = "https://ipfs.moralis.io:2053/ipfs/QmQabd3qV52jZzBB6WDKSjtW9TY2DwjnWgLuib3Jh6KDN9/Windry" ;         
            tp = "Air";
            description = "Windry; the small wind mintie. Its great mobility allows it to find home in many places. It seems to prefer mountains, and its friendly nature makes it easy for it to life with other minties.";
        }

        _safeMint(msg.sender, tokenId-1);
        _setTokenURI(tokenId-1,name,image,"2",tp, description);

        return tokenId-1;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 _tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        require(from == address(0), "Err: token transfer is BLOCKED");
        super._beforeTokenTransfer(from, to, _tokenId, batchSize);
    }

    function _burn(uint256 _tokenId) internal override {
        super._burn(_tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, FirstMintmonUriStorage)
        returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}