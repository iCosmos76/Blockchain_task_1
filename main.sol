pragma solidity ^0.8.18;

contract Computer_Storage {
    mapping(address => address[]) private computers;
    mapping(address => mapping(address => string)) private computer_name;

    function getComputers() public view returns (address[] memory) {
        return computers[msg.sender];
    }

    function addComputer(address computerAddress, string memory computerName) public {
        computers[msg.sender].push(computerAddress);
        computer_name[msg.sender][computerAddress] = computerName;
    }

    function getComputerName(address computerAddress) public view returns (string memory) {
        return computer_name[msg.sender][computerAddress];
    }

    function removeComputer(address computerAddress) public {
        uint256 length = computers[msg.sender].length;
        for (uint256 i = 0; i < length; i++) {
            if (computerAddress == computers[msg.sender][i]) {
                if (computers[msg.sender].length > 1 && i < length - 1) {
                    computers[msg.sender][i] = computers[msg.sender][length - 1];
                }

                delete computers[msg.sender][length - 1];
                computers[msg.sender].pop();

                delete computer_name[msg.sender][computerAddress];
                break;
            }
        }
    }
}