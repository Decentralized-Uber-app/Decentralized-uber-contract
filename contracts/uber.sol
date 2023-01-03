// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./UserVault.sol";
import "./DriverVault.sol";

contract Uber {

    // STATE VARIABLES //
    address owner;
    address[] driversAddress;
    address[] driverReviewers;
    address[] ridersAddress;
    address[] approvedDrivers;
    address tokenAddress;
    uint public driveFeePerTime;
    uint public driveFeePerDistance;

    constructor(address _tokenAddress) {
        owner == msg.sender;
        tokenAddress = _tokenAddress;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an admin");
        _;
    }

    struct DriverDetails{
        address driversAddress;
        string driversName;
        string driversLicense;
        bool registered;
        bool approved;
        bool available;
        bool rideRequest; // when a user request for ride
        bool acceptRide; // Driver accepts requested 
        bool booked; // When driver accepts ride
        uint timePicked;
        uint successfulRide;
        address currentRider;
        DriverVault vaultAddress;
    }

    struct RiderDetails{
        address ridersAddress;
        bool registered;
        bool ridepicked;
        UserVault vaultAddress;
    }


    mapping(address => DriverDetails) driverdetails;
    mapping(address => RiderDetails) riderdetails;


    ///Drivers ////
    function driversRegister(string memory _drivername, string memory _driverslicense) public {
        DriverDetails storage dd = driverdetails[msg.sender];
        require(dd.registered == false, "already registered");
        dd.driversAddress = msg.sender;
        dd.driversName = _drivername;
        dd.registered = true;
        dd.driversLicense = _driverslicense;
        driversAddress.push(msg.sender);
    }

    function reviewDriver(address _driversAddress) public onlyOwner{
        DriverDetails storage dd = driverdetails[_driversAddress];
        dd.approved = true;
        DriverVault newVault = new DriverVault(_driversAddress, tokenAddress);
        dd.vaultAddress = newVault;
    }

    //Riders////////
    function userRegistration() public {
        RiderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == false, "already registered");
        rd.ridersAddress = msg.sender;
        rd.registered = true;
        ridersAddress.push(msg.sender);
        UserVault newVault = new UserVault(msg.sender, tokenAddress, address(this));
        rd.vaultAddress = newVault;
    }

    function orderRide(address _driver, uint _distance) public {
        RiderDetails storage rd = riderdetails[msg.sender];
        address ridersVault = address(rd.vaultAddress);
        uint estimatedDriveFee =  calFeeEstimate(_distance);
        require(IERC20(tokenAddress).balanceOf(ridersVault) >= estimatedDriveFee, "Low balance");
        require(rd.registered == true, "not registered");
        require(rd.ridepicked == false, "You have a ride in progress/you have balance to pay");
        DriverDetails storage DD = driverdetails[_driver];
        require(DD.booked == false, "Rider booked");
        require(DD.available == true, "Driver not available");
        DD.rideRequest = true;
        DD.currentRider = msg.sender;
        rd.ridepicked = true;
    }

    function driverAcceptRide ()public {
       DriverDetails storage DD = driverdetails[msg.sender];
       require(DD.rideRequest == true, "No ride requested");
       DD.booked = true;
       DD.timePicked = block.timestamp;
    }
  

    function endride() public{
        DriverDetails storage dd = driverdetails[msg.sender];
        RiderDetails storage rd = riderdetails[dd.currentRider];
        require(dd.booked == true, "you have no active ride");
        uint amount = calcRealFee(dd.driversAddress);
        IERC20(tokenAddress).transferFrom(address(rd.vaultAddress), address(dd.vaultAddress), amount);
        dd.currentRider = address(0);
        dd.booked = false;
        dd.acceptRide = false;
        dd.rideRequest = false;
        dd.successfulRide += 1;
        rd.ridepicked = false;
    }

    function addReviewers(address reviewersAddress) public onlyOwner{
        driverReviewers.push(reviewersAddress);
    }

    function calFeeEstimate (uint _distance) public view returns(uint estimateFee) {
        estimateFee = _distance * driveFeePerDistance;
    }

    function isUserInRide (address _owner) public view returns (bool rideOngoing) {
        RiderDetails memory rd = riderdetails[_owner];
        rideOngoing = rd.ridepicked;
    }

    function calcRealFee(address driverAddress) internal view returns(uint256 amountToPay){
        DriverDetails storage dd = driverdetails[driverAddress];
        uint totalTime = block.timestamp - dd.timePicked;
         amountToPay = totalTime * driveFeePerTime;
    }


    function setRideFeePerTime (uint fee) external onlyOwner {
        driveFeePerTime = fee;
    }

    function setRideFeePerDistance (uint fee) external onlyOwner {
        driveFeePerDistance = fee;
    }

    function setContractAddress (address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }

    function viewAllDrivers () external view returns(address[] memory) {
        return driversAddress;
    }
    function viewAllRiders () external view returns(address[] memory) {
        return ridersAddress;
    }

    function changeTokenAddress(address _newTokenAddress) external{
        tokenAddress = _newTokenAddress;
    }
    
}