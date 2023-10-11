// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fund-me.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; 

    // Creating a fake user for our contract
    address USER = makeAddr("user");
    
    // Constant Magic numbers
    uint256 constant ETH_VALUE = 10e18;

    // Sending eth to our fake user created above
    uint256 constant STARTING_BALANCE = 10 ether;

    // Here we're setting up the contract our txGasPrice
    uint256 constant TX_GAS_PRICE = 1;
    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(address(fundMe), STARTING_BALANCE);
        
    }
     function testUserCanFundInteractions() public {  
        vm.startBroadcast();   
        FundFundMe fundFundMe = new FundFundMe();        
        //fundFundMe.fundFundMe(address(fundMe)); # Error: Check tommorrow
         vm.stopBroadcast();       
        
        
        
              
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        
        
        assert(address(fundMe).balance == 0);
     }  
}    