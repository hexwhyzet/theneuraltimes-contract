pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/utils/Counters.sol";
import "OpenZeppelin/openzeppelin-contracts@4.6.0/contracts/utils/math/SafeMath.sol";

contract TheNeuralTimes is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _lastTokenId;

    constructor() ERC721("TNT", "TheNeuralTimes") {}

    uint256 public maxSupply = 0;
    bool public lockedMaxSupply = false;
    string public baseURI = "https://theneuraltimes.com/resources/";
    bool public lockedBaseURI = false;

    function leftToMint() public view returns (uint256) {
        return maxSupply - _lastTokenId.current();
    }

    modifier amountToMintChecker(uint256 amountToMint) {
        require(amountToMint > 0, "Can't mint 0 tokens");
        require(amountToMint <= leftToMint(), "Fewer tokens left than requested");
        _;
    }

    function mint(address to, uint256 amountToMint) public onlyOwner amountToMintChecker(amountToMint) {
        for (uint256 i = 0; i < amountToMint; i++) {
            _safeMint(to, _lastTokenId.current() + 1);
            _lastTokenId.increment();
        }
    }

    function changeMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(!lockedMaxSupply, "Max supply is locked");
        maxSupply = newMaxSupply;
    }

    function lockMaxSupply() public onlyOwner {
        require(!lockedMaxSupply, "Max supply is already locked");
        lockedMaxSupply = true;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        require(!lockedBaseURI, "Base URI is locked");
        baseURI = newBaseURI;
    }

    function lockBaseURI() public onlyOwner {
        require(!lockedBaseURI, "Base URI is already locked");
        lockedBaseURI = true;
    }

    function _baseURI() internal override view returns (string memory) {
        return baseURI;
    }

    function withdrawFunds() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}