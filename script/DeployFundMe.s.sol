//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //  address priceFeed = helperConfig.getConfigByChainId(block.chainid).priceFeed;

        HelperConfig helperConfig = new HelperConfig(); // reason behind to use HelperConfig before broadcast is that we do not want to spend gas on the chain for deploying the contract
        //Anything before vm.startBroadcast() -> Not a "real" transaction
        //Anything after vm.stopBroadcast() -> "real" transaction
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
