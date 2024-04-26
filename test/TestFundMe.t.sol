//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeDeploy} from "../script/FundMeDeploy.s.sol";

contract TestFundMe is Test {

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS = 1;

    FundMe fundMe;
    function setUp() external {
        FundMeDeploy deploy = new FundMeDeploy();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() view public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() view public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionNumberIsFour() view public{
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
            vm.expectRevert();
            fundMe.fund();
    }

    function testUserAndMsgSenderAreNotTheSameTheSame() public {
        vm.prank(USER);
        console.log(msg.sender);
        console.log(address(USER));
        vm.expectRevert();
        assertEq(msg.sender,address(USER));
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        console.log(msg.sender);
        console.log(address(this));
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); 
        assertEq(amountFunded, 1 ether);
    }

    function testAddsFunderToArrayOfFunders() public {
        //looking to see if funder is added to the array
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOwnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        //Arrange

        uint256 balanceBefore = fundMe.getOwner().balance;
        uint256 balanceBeforeContract = address(fundMe).balance;
        //Act
        uint256 gastStart = gasleft();
        vm.txGasPrice(GAS);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();  
        uint256 gasEnd = gasleft();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(balanceBefore + balanceBeforeContract, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
            //Arrange
            uint160 numberOfFunders = 10;
            uint160 startingFunderIndex = 1;
            for(uint160 i= startingFunderIndex; i < numberOfFunders; i++) {
                hoax(address(i), 2 ether);
                fundMe.fund{value: 1 ether}();
            }

            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
            //Act
            vm.startPrank(address(fundMe.getOwner()));
            fundMe.withdraw();
            vm.stopPrank();

            //Assert
            assert(address(fundMe).balance ==0);
            assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}
