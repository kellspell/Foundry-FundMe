// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fund-me.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundeMeTest is Test {
    // To All the Functions in our Test contract be able to access the FundMe contract
    // we need to make the FundMe contract a global variable, like this all the functions can access it
    FundMe fundMe; 

    // Creating a fake user for our contract
    address USER = makeAddr("user");
    
    // Constant Magic numbers
    uint256 constant ETH_VALUE = 10e18;

    // Sending eth to our fake user created above
    uint256 constant STARTING_BALANCE = 10 ether;

    // Here we're setting up the contract our txGasPrice
    uint256 constant TX_GAS_PRICE = 1;

    function setUp() external { // Here we're setting up the contract
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimunDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public {
        //console.log(fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testFundFailsWithoutEnoughtEth() public {
        vm.expectRevert();
        fundMe.fund();
        
    }
    function testFundUpdatesDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: ETH_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFund(USER);
        assert(amountFunded == ETH_VALUE );
    }

    function testAddsFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: ETH_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    // Here we're creating a fake user for our contract to make easier to work with
    // instead to stay creating this vm.prank(user) all the time 
    modifier FakeUserFunded() {
        vm.prank(USER);
        fundMe.fund{value: ETH_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public FakeUserFunded{

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder () public FakeUserFunded {
        // Arrange
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act 
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    // Here we're going to test the contact with multiple funder
    function testWithDrawFromMultipleFunders () public FakeUserFunded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 stratingFunderIndex = 1;
        // the reason we startinf our index from 1 positions abouve its because sometimes the 0 address reverts and dosen't 
        // works as its should 

        for (uint160 i = stratingFunderIndex; i < numberOfFunders; i++){
            hoax(address(1), ETH_VALUE);
            fundMe.fund{value: ETH_VALUE}();
            
        }
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft(); // this gasleft is buildin function in solidity, tell you how much gas is left after the transaction called
        vm.txGasPrice(TX_GAS_PRICE); // here is our txGasPrice add in order to save gas 
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft(); // this gasleft after the transaction called
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // This is another solidity buildtin function 
        console.log(gasUsed);

        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
    function testWithDrawFromMultipleFundersCheaper () public FakeUserFunded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 stratingFunderIndex = 1;
        // the reason we startinf our index from 1 positions abouve its because sometimes the 0 address reverts and dosen't 
        // works as its should 

        for (uint160 i = stratingFunderIndex; i < numberOfFunders; i++){
            hoax(address(1), ETH_VALUE);
            fundMe.fund{value: ETH_VALUE}();
            
        }
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft(); // this gasleft is buildin function in solidity, tell you how much gas is left after the transaction called
        vm.txGasPrice(TX_GAS_PRICE); // here is our txGasPrice add in order to save gas 
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 gasEnd = gasleft(); // this gasleft after the transaction called
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // This is another solidity buildtin function 
        console.log(gasUsed);
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}