//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;
pragma abicoder v2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "./MintmonsUriStorage.sol";

interface Turnstile {
    function register(address) external returns (uint256);
}

contract Mintmons is MintmonsUriStorage, EIP712, AccessControl, Ownable {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  string private constant SIGNING_DOMAIN = "Mintmon-Voucher";
  string private constant SIGNATURE_VERSION = "1";

  uint256 _tokenId;
  bool public mintState;

  event MintmonLevelUpdate(uint256 indexed _tokenId, string indexed _level);
  event MintmonImageAndLevelUpdate(uint256 indexed _tokenId, string indexed _level, string _image);

  // CSR for Canto
  Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);

  constructor(address minter)
    ERC721("Mintmon", "MTM") 
    EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
      _setupRole(MINTER_ROLE, minter);
      _tokenId = 1;
      mintState = true;
      turnstile.register(tx.origin);
    }

  struct NFTVoucher {
    uint256 tokenId;
    string name;
    string level;
    string image;
    string tp;
    string description;
    bytes signature;
  }


  /// @notice Redeems an NFTVoucher for an actual NFT, creating it in the process.
  /// @param redeemer The address of the account which will receive the NFT upon success.
  /// @param voucher A signed NFTVoucher that describes the NFT to be redeemed.
  function redeem(address redeemer, NFTVoucher calldata voucher) public returns (uint256) {
    require(mintState, "Minting is paused");
    // make sure signature is valid and get the address of the signer
    address signer = _verify(voucher);

    // make sure that the signer is authorized to mint NFTs
    require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized");

    _tokenId ++;
    _mint(redeemer, _tokenId-1);
    _setTokenURI(_tokenId-1,voucher.name, voucher.image, voucher.level, voucher.tp, voucher.description);
    
    return _tokenId-1;
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
