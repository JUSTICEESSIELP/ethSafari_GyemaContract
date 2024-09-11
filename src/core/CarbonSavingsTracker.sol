// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract CarbonSavingsTracker {
    mapping(uint256 => uint256) public deliveryCarbonSavings;
    mapping(address => uint256) public userCarbonSavings;

    event CarbonSavingsLogged(uint256 indexed deliveryId, uint256 carbonSavings);
    event UserCarbonSavingsUpdated(address indexed user, uint256 totalCarbonSavings);

    function logSavings(uint256 _deliveryId, uint256 _carbonSavings) public {
        deliveryCarbonSavings[_deliveryId] += _carbonSavings;
        emit CarbonSavingsLogged(_deliveryId, _carbonSavings);
    }

    function updateUserSavings(address _user, uint256 _carbonSavings) public {
        userCarbonSavings[_user] += _carbonSavings;
        emit UserCarbonSavingsUpdated(_user, userCarbonSavings[_user]);
    }

    function getDeliverySavings(uint256 _deliveryId) public view returns (uint256) {
        return deliveryCarbonSavings[_deliveryId];
    }

    function getUserSavings(address _user) public view returns (uint256) {
        return userCarbonSavings[_user];
    }
}