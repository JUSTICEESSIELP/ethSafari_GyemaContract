// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


contract DriverRegistry {
    struct Driver {
        bool isRegistered;
        string name;
        string vehicleType;
        string licensePlate;
        uint256 rating;
        uint256 totalRatings;
    }

    mapping(address => Driver) public drivers;

    event DriverRegistered(address indexed driverAddress, string name, string vehicleType);
    event DriverRated(address indexed driverAddress, uint256 newRating);

    function registerDriver(string memory _name, string memory _vehicleType, string memory _licensePlate) public {
        require(!drivers[msg.sender].isRegistered, "Driver already registered");
        drivers[msg.sender] = Driver(true, _name, _vehicleType, _licensePlate, 0, 0);
        emit DriverRegistered(msg.sender, _name, _vehicleType);
    }

    function updateDriverInfo(string memory _name, string memory _vehicleType, string memory _licensePlate) public {
        require(drivers[msg.sender].isRegistered, "Driver not registered");
        Driver storage driver = drivers[msg.sender];
        driver.name = _name;
        driver.vehicleType = _vehicleType;
        driver.licensePlate = _licensePlate;
    }

    function rateDriver(address _driverAddress, uint256 _rating) public {
        require(drivers[_driverAddress].isRegistered, "Driver not registered");
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        Driver storage driver = drivers[_driverAddress];
        uint256 totalRating = driver.rating * driver.totalRatings;
        totalRating += _rating;
        driver.totalRatings++;
        driver.rating = totalRating / driver.totalRatings;
        emit DriverRated(_driverAddress, driver.rating);
    }

    function getDriverInfo(address _driverAddress) public view returns (string memory, string memory, string memory, uint256) {
        require(drivers[_driverAddress].isRegistered, "Driver not registered");
        Driver memory driver = drivers[_driverAddress];
        return (driver.name, driver.vehicleType, driver.licensePlate, driver.rating);
    }
}
