//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    uint8 public constant DECIMALS = 8;
    int256 public constant INITAL_ANSWER = 2000e8;
    ConfigType public activeConfig;

    struct ConfigType{
        address priceFeed; //ETH USD Price Feed Address
    }

    constructor() {
        if(block.chainid == 11155111){
        activeConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1){
        activeConfig = getMainnetEthConfig();
        }
        else if(block.chainid == 111111){
        activeConfig = getBaseSepoliaEthConfig();
        }
        else {
        activeConfig = getOrCreateAnvilEthConfig();
    }
    } 

    function getSepoliaEthConfig() public pure returns(ConfigType memory) {
        ConfigType memory sepoliaConfig = ConfigType({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

     function getMainnetEthConfig() public pure returns(ConfigType memory) {
        ConfigType memory sepoliaConfig = ConfigType({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return sepoliaConfig;
    }

     function getBaseSepoliaEthConfig() public pure returns(ConfigType memory) {
        ConfigType memory sepoliaConfig = ConfigType({priceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(ConfigType memory) {
        if(activeConfig.priceFeed != address(0)) {
            return activeConfig;
        }
        //deploy the mocks
        //return the mock address

        vm.startBroadcast();
        MockV3Aggregator mock = new MockV3Aggregator(DECIMALS, INITAL_ANSWER);
        vm.stopBroadcast(); 

        ConfigType memory anvilConfig = ConfigType({priceFeed: address(mock)
        });
        return anvilConfig;
    }
}

//Deploy mocks when we're on a local anvil chain 

//Keep  track of contract addresses accross different chains