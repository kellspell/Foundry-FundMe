// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fund-me.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run () external returns (FundMe) {
        // Everything before start the Broadcast -> Not sent as a real transaction
        HelperConfig helpConfig = new HelperConfig();
        address priceFeed = helpConfig.activeNetworkConfig();
        
        
        // After start the Broadcast -> is a real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}