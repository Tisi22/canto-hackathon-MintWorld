// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract FirstMintmonUriStorage is ERC721 {

    struct DataURI{
        string name;
        string image;  
        string level;
        string tp;
        string description;
    }

    mapping (uint256 => DataURI) mintmonsURI;

    constructor(){
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        DataURI memory data = mintmonsURI[tokenId];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', data.name,
                        '","description":"',data.description, 
                        '", "image": "', data.image,
                        '","attributes": [ { "trait_type": "Type", "value": ',
                        data.tp,
                        '}, { "trait_type": "Level", "value": ',
                        data.level,
                        "} ]}"
                    )

                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function _setTokenURI(uint256 tokenId, string memory _name, string memory _image, string memory _level, string memory _tp, string memory _description) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");
        mintmonsURI[tokenId].name = _name;
        mintmonsURI[tokenId].image = _image;
        mintmonsURI[tokenId].level = _level;
        mintmonsURI[tokenId].tp = _tp;
        mintmonsURI[tokenId].description = _description;
    }

    function _updateLevel(uint256 tokenId,  string memory _level) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");
        mintmonsURI[tokenId].level = _level;
    }

    function _updateImageAndLevel(uint256 tokenId,  string memory _image, string memory _level) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");
        mintmonsURI[tokenId].image = _image;
        mintmonsURI[tokenId].level = _level;
    }
 
}