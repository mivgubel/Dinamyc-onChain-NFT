// SPDX-License-Identifier: MIT

// POLYGON MUMBAI CONTRACT: 0xb8552eAd3A401fD91BD3eDf3655cDAE892356142

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) public tokenIdtoLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: red; font-family: Arial; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(_tokenId),
            "</text>",
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevels(uint256 _tokenId) public view returns (string memory) {
        uint256 level = tokenIdtoLevels[_tokenId];
        return level.toString();
    }

    function getTokenURI(uint256 _tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            _tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(_tokenId),
            '"',
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    // function to mint the NFTS
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdtoLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    // function to train your character
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token ID");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it"
        );
        uint256 currentLevel = tokenIdtoLevels[tokenId];
        tokenIdtoLevels[tokenId] = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
