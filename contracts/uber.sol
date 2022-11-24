// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Uber {

    // STATE VARIABLES //
    address owner;
    address[] driversAddress;
    address[] driverReviewers;
    address[] ridersAddress;

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
        uint successfulRide;
        address currentRider;
    }

    struct riderDetails{
        address ridersAddress;
        uint ridefee;
        bool needride;
        bool registered;
        bool ridepicked;
        bool paid;
    }


    mapping(address => driverDetails) driverdetails;
    mapping(address => riderDetails) riderdetails;


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

    function reviewDriver(address _driversAddress) public{
        driverDetails storage dd = driverdetails[_driversAddress];
        dd.approved = true;
    }


    //Riders////////
    function ridersRegistration() public {
        riderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == false, "already registered");
        rd.ridersAddress = msg.sender;
        rd.registered = true;
        ridersAddress.push(msg.sender);

    }

    function orderRide() public {
        riderDetails storage rd = riderdetails[msg.sender];
        require(rd.registered == true, "not registered");
        require(rd.needride == false, "You have a ride in progress/you have balance to pay");
        rd.needride = true;

    }

    function pickRide() public {
        driverDetails storage dd = driverdetails[msg.sender];
        require(dd.registered == true, "not registered");
        require(dd.approved == true, "approval still pendind");
        require(dd.booked == false, "already booked");
        dd.timePicked = block.timestamp;
        dd.booked = true;

        for (uint i=0; i<ridersAddress.length; i++) {
            if(riderdetails[ridersAddress[i]].needride == true){
                dd.currentRider = ridersAddress[i];     
            }
             
        }
        
    }

    function payFee () public payable{
        riderDetails storage rd = riderdetails[msg.sender];
        require(rd.paid == false, "already paid");
        uint amount = rd.ridefee;
        payable(address(this)).transfer(amount);
        rd.ridefee = 0;
        rd.paid = true;
    }

    function endride() public{
        driverDetails storage dd = driverdetails[msg.sender];
        require(dd.booked == true, "you have no active ride");
        dd.timeDestination = block.timestamp;

        uint amount = calcFee();

        riderDetails storage rd = riderdetails[dd.currentRider];
        rd.ridefee = amount;
        dd.currentRider = address(0);
        dd.booked = false;
        dd.successfulRide += 1;
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