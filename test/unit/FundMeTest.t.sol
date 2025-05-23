//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test {

    FundMe public fundMe; // yaha hume instance lena pdega FundMe contract ka kuki hum direct FundMe contract use nhi kr skte kuki wo abhi deployed nhi hai and in Ethereum we can't interact with a contract that is not deployed yet

    address USER = makeAddr("user"); // yaha hum ek address bana rhe hai jo user ka address hoga

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe(); // yaha hum DeployFundMe contract ka instance le rhe hai taki is test me deployFundMe contract ko use karke FundMe contract ko deploy kar sake
        fundMe = deployFundMe.run(); // now here we store the address of deploy contract FundMe
        vm.deal(USER, STARTING_BALANCE); // yaha hum USER ko 10 ether de rhe hai taki wo fundMe contract me fund kar sake
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

   function testFundMeFailWithoutEnoughETH() public {
    vm.expectRevert(); // hey, the next line should revert!
    //assert (this tx fails/reverts)
    fundMe.fund(); // this function should revert
   }

   function testFundUpdatesFundedDataStructure() public {
    vm.prank(USER); // The next TX will be sent by USER
    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
   }

   function testAddsFunderToArrayOfFunders() public {
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

   function testOnlyOwnerCanWithdraw() public funded{

    vm.prank(USER);
    vm.expectRevert(); // hey, the next line should revert!
    fundMe.withdraw(); // this function should revert
   }

   function testWithDrawWithASingleFunder() public funded {
    //Arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    //Act 
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    //Assert 
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(endingFundMeBalance, 0);
    assertEq(
        startingOwnerBalance + startingFundMeBalance,
        endingOwnerBalance
    );
   }

   function testWithdrawFromMultipleFunders() public funded {
     //Arrange 
     uint160 numberOfFunders = 10;
     uint160 startingFunderIndex = 1;
     for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
       //vm.prank new address
       //vm.deal new address
       //address ()

       hoax(address(i), SEND_VALUE);
       fundMe.fund{value: SEND_VALUE}();
     }

     uint256 startingOwnerBalance = fundMe.getOwner().balance;
     uint256 startingFundMeBalance = address(fundMe).balance;

     //Act

     vm.startPrank(fundMe.getOwner());
     fundMe.cheaperWithdraw();
     vm.stopPrank();

     //Assert 
     assert(address(fundMe).balance == 0);
     assert(
        startingFundMeBalance + startingOwnerBalance ==
        fundMe.getOwner().balance
     );

   }
} 