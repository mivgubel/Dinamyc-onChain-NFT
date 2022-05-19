// SPDX-License-Identifier: MIT

// POLYGON MUMBAI CONTRACT: 0x4Ed018c79FC171cc66E0149f633f0596e7E6ced4

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Struct to track the statistics
    struct stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    mapping(uint256 => stats) public tokenIdtoLevels;

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
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            getLevels(_tokenId),
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
        uint256 level = tokenIdtoLevels[_tokenId].level;
        uint256 speed = tokenIdtoLevels[_tokenId].speed;
        uint256 strength = tokenIdtoLevels[_tokenId].strength;
        uint256 life = tokenIdtoLevels[_tokenId].life;
        return
            string(
                abi.encodePacked(
                    '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
                    "Levels: ",
                    level.toString(),
                    "</text>",
                    '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
                    "Speed: ",
                    speed.toString(),
                    "</text>",
                    '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
                    "Strength: ",
                    strength.toString(),
                    "</text>",
                    '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
                    "Life: ",
                    life.toString(),
                    "</text>"
                )
            );
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
        // Initializing the stats
        tokenIdtoLevels[newItemId].level = 0;
        tokenIdtoLevels[newItemId].speed = 0;
        tokenIdtoLevels[newItemId].strength = 0;
        tokenIdtoLevels[newItemId].life = 1;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    // function to train your characters
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token ID");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it"
        );

        // we call random fuction and update the statistics

        uint256 randNumber = random();
        tokenIdtoLevels[tokenId].level += randNumber;
        tokenIdtoLevels[tokenId].speed += randNumber;
        tokenIdtoLevels[tokenId].strength += randNumber;
        tokenIdtoLevels[tokenId].life += randNumber;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    //function to generate a pseudo random number in the blockchain.
    function random() private view returns (uint256) {
        // retornamos un entero pseudo random entre 0 - 9 para ir subiendo habilidades poco a poco, tomando como base los parametros pasados al abi.enconde.
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % 10;
    }
}
