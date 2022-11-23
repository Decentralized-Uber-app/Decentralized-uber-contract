// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract uberDrive{
    address owner;

    constructor() {
        owner == msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not an admin");
        _;
    }

    struct driverDetails{
        address driversAddress;
        string driversName;
        bool registered;
        bool approved;
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
    address[] driverReviewers;

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
        dd.approved = false;
        driversAddress.push(msg.sender);
    }

    function reviewDriver(address driversAddress) public{
        driverDetails storage dd = driverdetails[driversAddress];
        dd.approved = true;
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
        require(dd.approved == true, "approval still pendind");
        require(dd.booked == false, "already booked");
        dd.timePicked = block.timestamp;
        dd.booked = true;
        
    }

    function payFee () public {
        riderDetails storage rd = riderdetails[msg.sender];

    }

    function endride() public{
        driverDetails storage dd = driverdetails[msg.sender];
        require(dd.booked == true, "you have no active ride");
        dd.timeDestination = block.timestamp;
        dd.booked = false;

        uint amount = calcFee();
    }

    function addReviewers(address reviewersAddress) public onlyOwner{
        driverReviewers.push(reviewersAddress);
    }

    function calcFee() internal returns(uint256){
        driverDetails storage dd = driverdetails[msg.sender];
        uint timepicked = dd.timePicked;
        uint timereach = dd.timeDestination;
        uint totalTime = timereach - timepicked;

        uint amountToPay = totalTime * 2;

        return amountToPay;

    }

    
}