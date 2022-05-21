// SPDX-License-Identifier: MIT

// POLYGON MUMBAI CONTRACT: 0x0d8dE01Be52E611D41FbD4C1D8172edC243511Ef

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract ChainBattles is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    // Your subscription ID.
    uint64 s_subscriptionId;

    // Mumbai coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 1 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 1;

    uint256 public s_randomWords; // save the randon number / shoul be ab array if we retrieve more that 1 random number.
    uint256 public s_requestId;
    address s_owner;

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

    constructor(uint64 subscriptionId)
        ERC721("Chain Battles", "CBTLS")
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    // Modifier onlyOwner
    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only the owner can call this function");
        _;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256,
        /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = (randomWords[0] % 10) + 1;
    }

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

        // uint256 randNumber = random();
        tokenIdtoLevels[tokenId].level += s_randomWords;
        tokenIdtoLevels[tokenId].speed += s_randomWords;
        tokenIdtoLevels[tokenId].strength += s_randomWords;
        tokenIdtoLevels[tokenId].life += s_randomWords;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    /*function to generate a pseudo random number in the blockchain.
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
    */
}
