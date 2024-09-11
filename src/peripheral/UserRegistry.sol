// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UserRegistry {
    struct User {
        bool isRegistered;
        string name;
        string contactInfo;
    }

    mapping(address => User) public users;

    event UserRegistered(address indexed userAddress, string name);

    function registerUser(string memory _name, string memory _contactInfo) public {
        require(!users[msg.sender].isRegistered, "User already registered");
        users[msg.sender] = User(true, _name, _contactInfo);
        emit UserRegistered(msg.sender, _name);
    }

    function updateUserInfo(string memory _name, string memory _contactInfo) public {
        require(users[msg.sender].isRegistered, "User not registered");
        users[msg.sender].name = _name;
        users[msg.sender].contactInfo = _contactInfo;
    }

    function getUserInfo(address _userAddress) public view returns (string memory, string memory) {
        require(users[_userAddress].isRegistered, "User not registered");
        return (users[_userAddress].name, users[_userAddress].contactInfo);
    }
}