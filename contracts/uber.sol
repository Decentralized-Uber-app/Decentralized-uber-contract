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

    constructor() {
        owner == msg.sender;
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
        bool booked;
        bool arrived;
        uint timePicked;
        uint timeDestination;
        uint successfulRide;
        address currentRider;
        DriverVault vaultAddress;
    }

    struct RiderDetails{
        address ridersAddress;
        uint ridefee;
        bool needride;
        bool registered;
        bool ridepicked;
        bool paid;
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

    function reviewDriver(address _driversAddress) public{
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
        UserVault newVault = new UserVault(msg.sender, tokenAddress);
        rd.vaultAddress = newVault;
    }

    function orderRide() public {
        RiderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == true, "not registered");
        require(rd.needride == false, "You have a ride in progress/you have balance to pay");
        rd.needride = true;
    }

    // Function needs to be worked on (Avoid loop in a write function)
    // function pickRide() public {
    //     driverDetails storage dd = driverdetails[msg.sender];
    //     require(dd.registered == true, "not registered");
    //     require(dd.approved == true, "approval still pendind");
    //     require(dd.booked == false, "already booked");
    //     dd.timePicked = block.timestamp;
    //     dd.booked = true;

    //     for (uint i=0; i<ridersAddress.length; i++) {
    //         if(riderdetails[ridersAddress[i]].needride == true){
    //             dd.currentRider = ridersAddress[i];     
    //         }
             
    //     }
        
    // }

    function payFee () public payable{
        RiderDetails storage rd = riderdetails[msg.sender];
        require(rd.paid == false, "already paid");
        uint amount = rd.ridefee;
        payable(address(this)).transfer(amount);
        rd.ridefee = 0;
        rd.paid = true;
    }

    function endride() public{
        DriverDetails storage dd = driverdetails[msg.sender];
        require(dd.booked == true, "you have no active ride");
        dd.timeDestination = block.timestamp;

        uint amount = calcFee();

        RiderDetails storage rd = riderdetails[dd.currentRider];
     //   rd.ridefee = amount;
        dd.currentRider = address(0);
        dd.booked = false;
        dd.successfulRide += 1;
    }

    function addReviewers(address reviewersAddress) public onlyOwner{
        driverReviewers.push(reviewersAddress);
    }

    function calcFee() internal view returns(uint256){
        DriverDetails storage dd = driverdetails[msg.sender];
        uint timepicked = dd.timePicked;
        uint timereach = dd.timeDestination;
        uint totalTime = timereach - timepicked;

        uint amountToPay = totalTime * 2;

        return amountToPay;
    }

    function setContractAddress (address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }
    
}