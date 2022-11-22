// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Uber {

    address owner;

    constructor() {
        owner == msg.sender;
    }

    struct driverDetails{
        address driversAddress;
        string driversName;
        bool registered;
        bool booked;
        bool arrived;
        uint timePicked;
        uint timeDestination ;    
    }

    struct riderDetails{
        address ridersAddress;
        bool registered;
        bool ridepicked;
        bool paid;
    }

    address[] driversAddress;

    mapping(address => driverDetails) driverdetails;
    mapping(address => riderDetails) riderdetails;

    // modifier registered(){
    //     riderDetails storage rd = riderdetails[msg.sender];
    //     require(rd)
    // }

    ///Drivers ////
    function driversRegister(string memory _drivername) public {
        driverDetails storage dd = driverdetails[msg.sender];
        require(dd.registered == false, "already registered");
        dd.driversAddress = msg.sender;
        dd.driversName = _drivername;
        dd.registered = true;
        driversAddress.push(msg.sender);
    }


    //Riders////////
    function ridersRegistration() public {
        riderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == false, "already registered");
        rd.ridersAddress = msg.sender;
        rd.registered = true;
    }

    function orderRide() public {
        riderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == true, "not registered");

    }

    function pickRide() public {
        driverDetails storage dd = driverdetails[msg.sender];
        require(dd.registered == true, "not registered");
        require(dd.booked == false, "already booked");

    }
  
}
