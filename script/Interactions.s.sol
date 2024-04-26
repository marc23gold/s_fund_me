//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
    uint256 constant VALUE = 1 ether;
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundme with %s",VALUE);
    }
    function run() external returns(FundMe) {
        address mostRecentDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        fundFundMe(mostRecentDeployedFundMe);   
    }
}

contract WithdrawFundMe is Script{

}