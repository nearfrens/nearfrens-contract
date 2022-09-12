// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract NearFrens {

    struct Latitude {
        int8 _degrees;
        int8 _minutes;
        int8 _seconds;
    }

    struct Longitude {
        int16 _degrees;
        int8 _minutes;
        int8 _seconds;
    }
    
    ///here we add the user in order to be able to track it's position in arrays to remove it.
    struct Position {
        Latitude _latitude;
        Longitude _longitude;
        uint256 _timestamp;
        address _user;
    }

    struct LastCheckInData {
        Position _position;
        address[] _collections;
        uint256 _zone;
    }

    mapping(address => LastCheckInData) private addressToLastCheckInData;
    mapping(address => Position[]) private addressToPosition;
    mapping(address => bool) active;
    
    ///Will return an array of positions for a specified collection + zone
    mapping(address => mapping(uint => Position[])) public collectionToZoneToPosition;


    /// function to call by front end to get the position in lat/long for specified collections (that user should own)
    function getPositionsforCollections(address[] memory collections, uint256 zone) external view returns (Position[] memory _data1, Position[] memory _data2, Position[] memory _data3) {
        require(collections.length < 4, "max 3 collections");

        Position[] memory data1 = collectionToZoneToPosition[collections[0]][zone];
        Position[] memory data2;
        Position[] memory data3;

        if(collections.length > 1) {
            data2 = collectionToZoneToPosition[collections[1]][zone];
        }
        if(collections.length > 2) {
            data3 = collectionToZoneToPosition[collections[2]][zone];
        }
        return(data1, data2, data3);

    }

    /// To Do: Put a check that requires the sender to be in possession of the NFT
    function checkIn(
        Latitude memory latitude,
        Longitude memory longitude,
        uint256 zoneID,
        address[] memory collections, 
        uint256[] memory tokenIDs) external {

        require(collections.length < 4, "Check in max for 3 collections");
        require(!active[msg.sender]);
        for(uint j = 0; j < tokenIDs.length; j++) {
            require(IERC721(collections[j]).ownerOf(tokenIDs[j]) == msg.sender);
        }
        
        Position memory positionData = Position(latitude, longitude, block.timestamp, msg.sender);
        addressToPosition[msg.sender].push(positionData);
        
        for(uint i = 0; i < collections.length; i++) {
            require(collectionToZoneToPosition[collections[i]][zoneID].length < 10000, "too much users checked in for this collection in this zone");
            collectionToZoneToPosition[collections[i]][zoneID].push(positionData);

        }

        LastCheckInData memory checkInData = LastCheckInData(positionData, collections, zoneID);
        addressToLastCheckInData[msg.sender] = checkInData;
        active[msg.sender] = true;
    }

    /// @dev This function locates the data of the user in the array: collectionToZoneToPosition
    ///       once located this data is removed by switching item index with last position and deleting last position.
    /// ToDo Optimize with for loop and use arrays for positionsIndex1,2,3...  
    function checkOut() external {
        require(active[msg.sender], "No active user");
        address[] memory listCollectionsUser = addressToLastCheckInData[msg.sender]._collections;
        uint256 zone = addressToLastCheckInData[msg.sender]._zone;

        Position[] memory positionsCollect1 = collectionToZoneToPosition[listCollectionsUser[0]][zone];
        Position[] memory positionsCollect2;
        Position[] memory positionsCollect3;
        uint256 positionIndex1 = getPositionInArray(positionsCollect1, msg.sender);
        uint256 positionIndex2;
        uint256 positionIndex3;

        if(listCollectionsUser.length > 1) {
            positionsCollect2 = collectionToZoneToPosition[listCollectionsUser[1]][zone];
            positionIndex2 = getPositionInArray(positionsCollect2, msg.sender);
            collectionToZoneToPosition[listCollectionsUser[1]][zone] = removeIndexElement(positionsCollect2, positionIndex2);
        }
        if(listCollectionsUser.length > 2) {
            positionsCollect3 = collectionToZoneToPosition[listCollectionsUser[2]][zone];
            positionIndex3 = getPositionInArray(positionsCollect2, msg.sender);
            collectionToZoneToPosition[listCollectionsUser[2]][zone] = removeIndexElement(positionsCollect3, positionIndex3);
        }

        collectionToZoneToPosition[listCollectionsUser[0]][zone] = removeIndexElement(positionsCollect1, positionIndex1);

        active[msg.sender] = false;
    }

    function getPositionInArray (Position[] memory positions, address user) private pure returns (uint256 positionIndex) {
        uint256 j = 0;
        for(uint256 i = 0; i < 10000 ; i++ ) {
            if(positions[i]._user == user) {
                break;
            }
            j++;

        }
        return j;
    }

    function removeIndexElement(Position[] memory positions, uint256 indexToRemove) private pure returns (Position[] memory updatedPositions) {

        positions[indexToRemove] = positions[positions.length - 1];
        delete positions[positions.length - 1];

        return positions;

    }

}
