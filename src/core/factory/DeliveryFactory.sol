// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeliveryContract.sol";

contract DeliveryFactory {
    DeliveryContractReactive public deliveryContract;

    event DeliveryContractCreated(address contractAddress);

    constructor(address _emissionsCalculator, address _carbonSavingsTracker) {
        deliveryContract = new DeliveryContractReactive(_emissionsCalculator, _carbonSavingsTracker);
        emit DeliveryContractCreated(address(deliveryContract));
    }

    function createDelivery(
        address _customer,
        string memory _pickupLocation,
        string memory _dropoffLocation,
        uint256 _packageWeight,
        uint256 _deadline,
        string[] memory _intermediateLocations,
        uint256[] memory _legDistances,
        uint256[] memory _estimatedStartTimes,
        uint256[] memory _estimatedEndTimes
    ) public returns (uint256) {
        return deliveryContract.createDelivery(
            _customer,
            _pickupLocation,
            _dropoffLocation,
            _packageWeight,
            _deadline,
            _intermediateLocations,
            _legDistances,
            _estimatedStartTimes,
            _estimatedEndTimes
        );
    }
}