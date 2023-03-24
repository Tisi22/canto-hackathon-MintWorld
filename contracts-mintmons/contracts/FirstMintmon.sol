// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
pragma abicoder v2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "./FirstMintmonUriStorage.sol";

contract FirstMintmon is FirstMintmonUriStorage, EIP712, AccessControl, Ownable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "Mintmon-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    bool public mintState;
    uint256 _tokenId;
    
    mapping(address => bool) firstMintmonMinted;
        struct NFTVoucher {
        uint256 tokenId;
        string name;
        string level;
        string image;
        string tp;
        string description;
        bytes signature;
    }

    event MintmonLevelUpdate(uint256 indexed _tokenId, string indexed _level);
    event MintmonImageAndLevelUpdate(uint256 indexed _tokenId, string indexed _level, string _image);

    constructor(address minter)
    ERC721("Mintmon", "MTM") 
    EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
      _setupRole(MINTER_ROLE, minter);
      _tokenId = 1;
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

        _tokenId++;

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

        _safeMint(msg.sender, _tokenId-1);
        _setTokenURI(_tokenId-1,name,image,"2",tp, description);

        return _tokenId-1;
    }

    function setMintstate(bool val) public onlyOwner{
        mintState = val;
    }

      function levelUpdate(NFTVoucher calldata voucher) public {

    // make sure signature is valid and get the address of the signer
    address signer = _verify(voucher);

    // make sure that the signer is authorized to mint NFTs
    require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

    _updateLevel(voucher.tokenId,  voucher.level);

    emit MintmonLevelUpdate(voucher.tokenId,  voucher.level);

  }

  function imageAndLevelUpdate(NFTVoucher calldata voucher) public {

    // make sure signature is valid and get the address of the signer
    address signer = _verify(voucher);

    // make sure that the signer is authorized to mint NFTs
    require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

    _updateImageAndLevel(voucher.tokenId,  voucher.image, voucher.level);

    emit MintmonImageAndLevelUpdate(voucher.tokenId,  voucher.level, voucher.image);

  }

  /// @notice Returns a hash of the given NFTVoucher, prepared using EIP712 typed data hashing rules.
  /// @param voucher An NFTVoucher to hash.
  function _hash(NFTVoucher calldata voucher) internal view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(
      keccak256("NFTVoucher(uint256 tokenId,string name,string level,string image,string tp,string description)"),
      voucher.tokenId,
      keccak256(bytes(voucher.name)),
      keccak256(bytes(voucher.level)),
      keccak256(bytes(voucher.image)),
      keccak256(bytes(voucher.tp)),
      keccak256(bytes(voucher.description))
    )));
  }

  /// @notice Returns the chain id of the current blockchain.
  /// @dev This is used to workaround an issue with ganache returning different values from the on-chain chainid() function and
  ///  the eth_chainId RPC method. See https://github.com/protocol/nft-website/issues/121 for context.
  function getChainID() external view returns (uint256) {
    uint256 id;
    assembly {
        id := chainid()
    }
    return id;
  }

  /// @notice Verifies the signature for a given NFTVoucher, returning the address of the signer.
  /// @dev Will revert if the signature is invalid. Does not verify that the signer is authorized to mint NFTs.
  /// @param voucher An NFTVoucher describing an unminted NFT.
  function _verify(NFTVoucher calldata voucher) internal view returns (address) {
    bytes32 digest = _hash(voucher);
    return ECDSA.recover(digest, voucher.signature);
  }

  
  /// @dev Returns all the tokenIds of a wallet
  function walletOfOwner(address _owner)
  public
  view
  returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
    uint256 currentTokenId = 1;
    uint256 ownedTokenIndex = 0;

    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= totalSupply()) {
      address currentTokenOwner = ownerOf(currentTokenId);

      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;

        ownedTokenIndex++;
      }

      currentTokenId++;
    }

    return ownedTokenIds;
  
  }

  function totalSupply() public view returns (uint256){
    return _tokenId-1;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControl, ERC721) returns (bool) {
    return ERC721.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
  }

}