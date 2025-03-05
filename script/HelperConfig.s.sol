// SPDX-License-Identifier:MIT 
// 1. deploy mocks when we are on local anvil chain
// 2. keep track of different addresses depending on chain 

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";
contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; 
    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;
    
    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory sapoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306}); 
        return sapoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvilConfig;
    }
}