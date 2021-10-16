// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//Importing openzeppelin-solidity ERC-721 implemented Standard
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    constructor () ERC721("Star Notary", "$STAR") {}

    // Star data
    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting a Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sell Star(s) you don't own");
        starsForSale[_tokenId] = _price;
    }



    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");

        uint starCost = starsForSale[_tokenId];
        uint buyerOffer = msg.value;
        bool buyerSentMoreThanRequired = buyerOffer > starCost;

        address ownerAddress = ownerOf(_tokenId);
        address buyerAddress = msg.sender;

        require(buyerSentMoreThanRequired, "Sufficient Eth is required");

        _transfer(ownerAddress, buyerAddress, _tokenId);
        payable(ownerAddress).transfer(starCost);

        if (buyerSentMoreThanRequired) {
            payable(buyerAddress).transfer(buyerOffer - starCost);
        }

        delete starsForSale[_tokenId];
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        //1. You should return the Star saved in tokenIdToStarInfo mapping
        return tokenIdToStarInfo[_tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)

        address ownerAddress1 = ownerOf(_tokenId1);
        address ownerAddress2 = ownerOf(_tokenId2);

        require(msg.sender == ownerAddress1 || msg.sender == ownerAddress2, "You need to own at least one of the tokens");

        //4. Use _transferFrom function to exchange the tokens.
        _transfer(ownerAddress1, ownerAddress2, _tokenId1);
        _transfer(ownerAddress2, ownerAddress1, _tokenId2);
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _recipient, uint256 _tokenId) public {
        safeTransferFrom(msg.sender, _recipient, _tokenId);
    }

}
