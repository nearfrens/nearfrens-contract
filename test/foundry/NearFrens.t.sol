// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//standard test libs
import "../../lib/forge-std/src/Test.sol";
import "../../lib/forge-std/src/Vm.sol";

//Contract under test
import {NearFrens} from "../../contracts/NearFrens.sol";

contract NearFrens_Test is Test {
    //Variable for contract instance
    NearFrens private nearfrens;
    uint256 mainnetFork;

    function setUp() public {
        //Instantiate new contract instance
        nearfrens = new NearFrens();
        //setup the fork
        mainnetFork = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Ug94oLpwQdXSMBKg8PTO3QnCE-dcBs8i");
        vm.selectFork(mainnetFork);
    }

    function testExample() public {

        vm.roll(100);
        assertTrue(true);
    }



}