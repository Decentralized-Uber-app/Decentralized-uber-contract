import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe ("Uber", () => {
    async function deployLoadFixture(){
        const [owner, driver, driver2, passenger, passsenger2, passenger3]  = await ethers.getSigners();

        const Ubercontract = await ethers.getContractFactory("Uber");
        const uberr = await Ubercontract.connect(owner).deploy("0x99E11732C5488Ad4b85ed93E46d23b46e736E6f9");

        return {owner, driver, driver2, passenger,passsenger2, passenger3, uberr}
    }

    describe("DriverRegister", () => {
        it("Should register the driver and revert if driver has registered before", async function () {
            const {uberr, owner, driver} = await loadFixture(deployLoadFixture);

            const Register = await ethers.getContractFactory("Uber");
            await uberr.connect(driver).driversRegister("Isaac", "YTT243547");

            await expect (uberr.connect(driver).driversRegister("Isaac", "YTT243547")).to.be.revertedWith("already registered");
            
        })

    })

    describe("PassengerRegistration", () => {
        it("Should register the passenger and revert if the passenger has registered before", async function () {
            const {uberr, passenger} = await loadFixture(deployLoadFixture);

            await uberr.connect(passenger).userRegistration();

            await expect (uberr.connect(passenger).userRegistration()).to.be.revertedWith("already registered")
        })
    })

    describe("ReviewDrivers", () => {
        it("Should approve the driver if driver has registered and met the requirements", async function(){
            const {uberr, owner, driver, passsenger2} = await loadFixture(deployLoadFixture);
            //Register the driver first to catch the state
            await uberr.connect(driver).driversRegister("CAS", "7RETHXG");
        
            await expect(uberr.connect(owner).reviewDriver(passsenger2.address)).not.to.be.reverted;
        })
    })

    // describe("OrderRide", () => {
    //     it("Should allow passenger to order a ride successfully", async function() {
    //         const {uberr, owner, driver2, passenger3} = await loadFixture(deployLoadFixture);

    //         await uberr.connect(passenger3).userRegistration()
    //         await uberr.connect(driver2).driversRegister("CAS", "7RETHXG");

    //         await uberr.connect(owner).reviewDriver(driver2.address);
    //         await expect(uberr.connect(passenger3).orderRide(driver2.address, 2345));
            
    //     })
    // })
})