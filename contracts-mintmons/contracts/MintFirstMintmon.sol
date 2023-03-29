// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

interface Turnstile {
    function register(address) external returns (uint256);
}

contract MintFirstMintmon is ERC721, Ownable{

    mapping(address => bool) public minted;
    uint256 public players;
    bool public mintState;

    // CSR for Canto
    Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);

    constructor() ERC721("FirstMintmon", "FMM") {
        tokenId = 1;
        turnstile.register(tx.origin);
    }

    function safeMint() public {
        require (mintState, "minting paused");
        require(!minted[msg.sender], "already minted");
        
        minted[msg.sender] = true;

        players++;

    }

    function checkMinted(address adr) public view returns(bool){
        return minted[adr];
    }

    function setMinted(address adr, bool val) public onlyOwner{
        minted[adr] = val;
    }

    function setMintstate(bool val) public onlyOwner{
        mintState = val;
    }
}