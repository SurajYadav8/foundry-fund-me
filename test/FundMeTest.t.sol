//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
contract FundMeTest is Test {

    FundMe public fundMe; // yaha hume instance lena pdega FundMe contract ka kuki hum direct FundMe contract use nhi kr skte kuki wo abhi deployed nhi hai and in Ethereum we can't interact with a contract that is not deployed yet

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe(); // yaha hum DeployFundMe contract ka instance le rhe hai taki is test me deployFundMe contract ko use karke FundMe contract ko deploy kar sake
        fundMe = deployFundMe.run(); // now here we store the address of deploy contract FundMe
    }

    function testMinimumDollarisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);// assert is series of functions that are used to test the code like here assertEq is used compare the value equal or not 
        // console.log("!");
        // console.log("123");
        // assertEq(number, 2);
    }
    
    function testOwnerisMessageSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

   function testPriceFeedVersionIsAccurate() public view{
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
   }
} 