// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract MintmonsUriStorage is ERC721 {

    struct DataURI{
        string name;
        string image;  
        string level;
        uint256 experience;
        string tp;
        string description;
        string attack1;
        string attack2;
        string attack3;
        string attack4;
    }

    struct NFTVoucher {
    uint256 tokenId;
    string name;
    string level;
    uint256 experience;
    string image;
    string tp;
    string description;
    string attack1;
    string attack2;
    string attack3;
    string attack4;
    bytes signature;
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
                        '", "level": "', data.level,
                        '", "experience": "', Strings.toString(data.experience),
                        '", "tokenId": "', Strings.toString(tokenId),
                        '","attributes": [ { "trait_type": "Type", "value": "',
                        data.tp,
                        '"}, { "trait_type": "Attack_1", "value": ',
                        data.attack1,
                        '"}, { "trait_type": "Attack_2", "value": ',
                        data.attack2,
                        '"}, { "trait_type": "Attack_3", "value": ',
                        data.attack3,
                        '"}, { "trait_type": "Attack_4", "value": ',
                        data.attack4,
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

    function _setTokenURI(uint256 tokenId, NFTVoucher calldata voucher) internal virtual {
        require(_exists(tokenId), "Token ID does not exist");
        mintmonsURI[tokenId].name = voucher.name;
        mintmonsURI[tokenId].image = voucher.image;
        mintmonsURI[tokenId].level = voucher.level;
        mintmonsURI[tokenId].experience = voucher.experience;
        mintmonsURI[tokenId].tp = voucher.tp;
        mintmonsURI[tokenId].description = voucher.description;
        mintmonsURI[tokenId].attack1 = voucher.attack1;
        mintmonsURI[tokenId].attack2 = voucher.attack2;
        mintmonsURI[tokenId].attack3 = voucher.attack3;
        mintmonsURI[tokenId].attack4 = voucher.attack4;
    }

    function _updateMetadata(NFTVoucher calldata voucher) internal virtual {
        require(_exists(voucher.tokenId), "Token ID does not exist");
        mintmonsURI[voucher.tokenId].name = voucher.name;
        mintmonsURI[voucher.tokenId].image = voucher.image;
        mintmonsURI[voucher.tokenId].level = voucher.level;
        mintmonsURI[voucher.tokenId].experience = voucher.experience;
        mintmonsURI[voucher.tokenId].tp = voucher.tp;
        mintmonsURI[voucher.tokenId].description = voucher.description;
        mintmonsURI[voucher.tokenId].attack1 = voucher.attack1;
        mintmonsURI[voucher.tokenId].attack2 = voucher.attack2;
        mintmonsURI[voucher.tokenId].attack3 = voucher.attack3;
        mintmonsURI[voucher.tokenId].attack4 = voucher.attack4;
    }
 
}