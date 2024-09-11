
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./EmissionsCalculator.sol";
import "./CarbonSavingsTracker.sol";
contract DeliveryContractReactive {
    struct DeliveryLeg {
        uint256 legId;
        address driver;
        string startLocation;
        string endLocation;
        uint256 distance;
        bool fulfilled;
        uint256 estimatedStartTime;
        uint256 estimatedEndTime;
    }

    struct DeliveryDetails {
        uint256 id;
        address customer;
        string pickupLocation;
        string dropoffLocation;
        uint256 packageWeight;
        uint256 deadline;
        bool fulfilled;
        DeliveryLeg[] legs;
        uint256 totalDistance;
        uint256 totalCarbonSavings;
    }

    mapping(uint256 => DeliveryDetails) public deliveries;
    uint256 public deliveryCounter;

    EmissionsCalculator public emissionsCalculator;
    CarbonSavingsTracker public carbonSavingsTracker;

    event DeliveryCreated(uint256 indexed deliveryId, address indexed customer);
    event LegAssigned(uint256 indexed deliveryId, uint256 indexed legId, address indexed driver);
    event LegFulfilled(uint256 indexed deliveryId, uint256 indexed legId, address indexed driver);
    event EmissionsCalculated(uint256 indexed deliveryId, uint256 indexed legId, uint256 carbonSavings);
    event NextDriverNotified(uint256 indexed deliveryId, uint256 indexed legId, address indexed nextDriver);
    event DeliveryCompleted(uint256 indexed deliveryId);

    constructor(address _emissionsCalculator, address _carbonSavingsTracker) {
        emissionsCalculator = EmissionsCalculator(_emissionsCalculator);
        carbonSavingsTracker = CarbonSavingsTracker(_carbonSavingsTracker);
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
        require(_intermediateLocations.length + 1 == _legDistances.length, "Invalid leg information");
        require(_legDistances.length == _estimatedStartTimes.length, "Invalid time information");
        require(_estimatedStartTimes.length == _estimatedEndTimes.length, "Invalid time information");

        deliveryCounter++;
        DeliveryDetails storage newDelivery = deliveries[deliveryCounter];

        newDelivery.id = deliveryCounter;
        newDelivery.customer = _customer;
        newDelivery.pickupLocation = _pickupLocation;
        newDelivery.dropoffLocation = _dropoffLocation;
        newDelivery.packageWeight = _packageWeight;
        newDelivery.deadline = _deadline;

        string memory previousLocation = _pickupLocation;
        for (uint256 i = 0; i <= _intermediateLocations.length; i++) {
            string memory endLocation = i < _intermediateLocations.length ? _intermediateLocations[i] : _dropoffLocation;
            newDelivery.legs.push(DeliveryLeg({
                legId: i,
                driver: address(0),
                startLocation: previousLocation,
                endLocation: endLocation,
                distance: _legDistances[i],
                fulfilled: false,
                estimatedStartTime: _estimatedStartTimes[i],
                estimatedEndTime: _estimatedEndTimes[i]
            }));
            newDelivery.totalDistance += _legDistances[i];
            previousLocation = endLocation;
        }

        emit DeliveryCreated(deliveryCounter, _customer);
        return deliveryCounter;
    }

    function acceptLeg(uint256 _deliveryId, uint256 _legId) public {
        DeliveryDetails storage delivery = deliveries[_deliveryId];
        require(_legId < delivery.legs.length, "Invalid leg ID");
        DeliveryLeg storage leg = delivery.legs[_legId];
        require(leg.driver == address(0), "Leg already assigned");
        leg.driver = msg.sender;
        emit LegAssigned(_deliveryId, _legId, msg.sender);
    }

    function completeLeg(uint256 _deliveryId, uint256 _legId) public {
        DeliveryDetails storage delivery = deliveries[_deliveryId];
        require(_legId < delivery.legs.length, "Invalid leg ID");
        DeliveryLeg storage leg = delivery.legs[_legId];
        require(msg.sender == leg.driver, "Not the assigned driver for this leg");
        require(!leg.fulfilled, "Leg already fulfilled");

        leg.fulfilled = true;
        emit LegFulfilled(_deliveryId, _legId, msg.sender);

        uint256 carbonSavings = emissionsCalculator.calculateCarbonSavings(_deliveryId, _legId, leg.distance);
        delivery.totalCarbonSavings += carbonSavings;
        carbonSavingsTracker.logSavings(_deliveryId, carbonSavings);
        emit EmissionsCalculated(_deliveryId, _legId, carbonSavings);

        if (_legId < delivery.legs.length - 1) {
            address nextDriver = delivery.legs[_legId + 1].driver;
            emit NextDriverNotified(_deliveryId, _legId + 1, nextDriver);
        } else {
            delivery.fulfilled = true;
            emit DeliveryCompleted(_deliveryId);
        }
    }

    function getDeliveryDetails(uint256 _deliveryId) public view returns (DeliveryDetails memory) {
        return deliveries[_deliveryId];
    }
}