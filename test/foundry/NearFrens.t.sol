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
    address bob = address(0x1);
    address alice = address(0x2);

    address NFTaddress1 = address(0x3);
    address NFTaddress2 = address(0x4);
    address NFTaddress3 = address(0x5);

    address[] NFT_contracts = [NFTaddress1, NFTaddress2, NFTaddress3];
    uint256[] tokenIds = [3, 28, 49];

    struct Positions {
        int32 latitude;
        int32 longitude;
        uint256 timestamp;
        address user;
    }



    function setUp() public {
        //Instantiate new contract instance
        nearfrens = new NearFrens();
        //setup the fork
        mainnetFork = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Ug94oLpwQdXSMBKg8PTO3QnCE-dcBs8i");
        vm.selectFork(mainnetFork);
    }

    function testCheckIn() public {
        vm.startPrank(bob);
        nearfrens.checkIn(387775416, -913519609, 1, NFT_contracts , tokenIds);
        (int32 lat, int32 long, uint256 timestamp, address user) = nearfrens.returnPositionData();
        
        emit log_int(lat);
        emit log_int(long);
        emit log_uint(timestamp);
        emit log_address(user);
        
    }



}