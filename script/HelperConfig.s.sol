// SPDX-License-Identifier: MIT

// The purpos of helperConfig file is to provide the configuration for the helper contract
// 1. Deploy mocks when we are on local anvil chain
//2. Keep track of contract address and abi across differents chains

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggragator.sol";

contract HelperConfig is Script {
    // if we are on local anvil, we deploy mocks
    // Otherwise , grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    // Constant Variables
    uint8 public constant Decimals = 8;
    int256 public constant Initial_Price = 2000e8;

    struct NetworkConfig {
        address priceFeed;
        // address ethConfig;
        // address ethConfigSepolia;
        // address ethConfigAnvil;
    }



    constructor() public {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
            
        }
        else {
            activeNetworkConfig =  getOrCreateAnvilEthConfig();
        }
    }
    
    // Sepolia Testnet
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
        });
    }

    // Ethereum Mainnet
    function getEthMainnetConfig() public pure returns (NetworkConfig memory ) {
        NetworkConfig memory EthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // ETH / USD
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory ) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
         vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(Decimals, Initial_Price);

         vm.stopBroadcast();

         NetworkConfig memory anvilConfig = NetworkConfig({
             priceFeed: address(mockPriceFeed)
         });
         return anvilConfig;
        // emit HelperConfig__CreatedMockPriceFeed(address(mockPriceFeed));

        // anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}