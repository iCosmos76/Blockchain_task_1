pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ComputersRent is ERC721 {
    struct Computer {
        string name;
        address owner;
        bool isRented;
        uint256 rentPricePerMinute;
        uint256 rentedUntil;
    }

    Computer[] public computers;
    mapping (uint256 => string) private _computerName;
    mapping(address => uint256) balances;

    mapping(address => uint256) private firstOwner;
    address[] firstOwners;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) payable {}

    function mint(address to, string memory computerName_, uint256 rentPricePerMinute) public returns (uint256) {
        uint256 tokenId = computers.length;
        computers.push(Computer(computerName_, to, false, rentPricePerMinute, 0));
        _computerName[tokenId] = computerName_;
        _mint(to, tokenId);
        firstOwner[to] = tokenId;
        firstOwners.push(to);
        return tokenId;
    }

    function rentByTime(uint256 tokenId, address to) public payable {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ComputersRent: not owner nor approved");
        require(computers[tokenId].isRented == false, "ComputersRent: computer is not rented");
        
        require(balances[to] >= computers[tokenId].rentPricePerMinute, "ComputersRent: not enough balance to pay for rent");
        require(_msgSender() != to, "ComputersRent: computer can only be rented to specified address");

        balances[to] -= computers[tokenId].rentPricePerMinute;

        (bool success,) = computers[tokenId].owner.call{value: computers[tokenId].rentPricePerMinute}("");
        require(success, "Failed to send funds");

        computers[tokenId].rentedUntil = block.timestamp + 60;

        computers[tokenId].isRented = true;
        _transfer(_msgSender(), to, tokenId);

    }

    function returnFromRent(uint256 tokenId, address from) public {

        address[] memory mAddresses = new address[](firstOwners.length);

        for (uint i = 0; i < firstOwners.length; i++){
            if (tokenId == firstOwner[firstOwners[i]]){
                mAddresses[i] = firstOwners[i];
                break;
            }
        }

        require(mAddresses[0] != from, "ComputersRent: owner can't return of token from yourself");
        require(mAddresses[0] == _msgSender(), "ComputersRent: you are not owner of this token");
        require(computers[tokenId].isRented == true, "ComputersRent: computer is not rented");
        require(block.timestamp >= computers[tokenId].rentedUntil, "ComputersRent: rent time has not yet expired");
        computers[tokenId].isRented = false;

        _transfer(from, mAddresses[0], tokenId);
    }

    function isRented(uint256 tokenId) public view returns (bool) {
        return computers[tokenId].isRented;
    }

    function computerName(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: computer name query for nonexistent token");
        return _computerName[tokenId];
    }

    function payRent(uint256 tokenId) public payable {
        require(computers[tokenId].isRented == false, "ComputersRent: computer is rented");
        require(_msgSender() != ownerOf(tokenId), "ComputersRent: owner cannot pay rent");
        require(msg.value == computers[tokenId].rentPricePerMinute, "ComputersRent: incorrect rent price");
        uint256 amount = msg.value;
        balances[_msgSender()] += amount;
    }

    function getBalances(address to) public view returns (uint256) {
        return balances[to];
    }
}