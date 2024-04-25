//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeDeploy} from "../script/FundMeDeploy.s.sol";

contract TestFundMe is Test {

    FundMe fundMe;
    function setUp() external {
        FundMeDeploy deploy = new FundMeDeploy();
        fundMe = deploy.run();
    }

    function testMinimumDollarIsFive() view public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() view public {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testVersionNumberIsFour() view public{
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }
}
