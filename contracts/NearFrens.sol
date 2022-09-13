// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract NearFrens {
    
    ///here we add the user in order to be able to track it's position in arrays to remove it.
    struct Position {
        int32 latitude;
        int32 longitude;
        uint256 timestamp;
        address user;
    }

    struct LastCheckInData {
        Position _position;
        address[] _collections;
        uint256 _zone;
    }

    mapping(address => LastCheckInData) public addressToLastCheckInData;
    mapping(address => Position[]) public addressToPosition;
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

    function returnPositionData() external view returns (int32, int32, uint256, address) {
        uint256 index = addressToPosition[msg.sender].length;
        Position memory lastPosition = addressToPosition[msg.sender][index - 1];
        return(lastPosition.longitude, lastPosition.latitude, lastPosition.timestamp, lastPosition.user);

    }

    /// To Do: Put a check that requires the sender to be in possession of the NFT
    function checkIn(
        int32 _latitude,
        int32 _longitude,
        uint256 _zoneID,
        address[] memory _collections, 
        uint256[] memory _tokenIDs) external {

        require(_collections.length < 4, "Check in max for 3 collections");
        require(!active[msg.sender]);
        //for(uint j = 0; j < _tokenIDs.length; j++) {
        //    require(IERC721(_collections[j]).ownerOf(_tokenIDs[j]) == msg.sender);
        //}
        
        
        Position storage p = addressToPosition[msg.sender].push();
        p.latitude = _latitude;
        p.longitude = _longitude;
        p.timestamp = block.timestamp;
        p.user = msg.sender;
        
        
        for(uint i = 0; i < _collections.length; i++) {
            require(collectionToZoneToPosition[_collections[i]][_zoneID].length < 10000, "too much users checked in for this collection in this zone");
            collectionToZoneToPosition[_collections[i]][_zoneID].push(p);

        }
        

        LastCheckInData memory checkInData = LastCheckInData(p, _collections, _zoneID);
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

        for(uint8 i = 0; i < listCollectionsUser.length; i++) {
            Position[] storage newArr = collectionToZoneToPosition[listCollectionsUser[i]][zone];
            uint256 j = 0;
            for(uint256 k = 0; k < 10000 ; k++ ) {
                if(newArr[k].user == msg.sender) {
                    break;
                }
                j++;

            } 
            newArr[j] = newArr[newArr.length - 1];
            delete newArr[newArr.length - 1];
            collectionToZoneToPosition[listCollectionsUser[i]][zone] = newArr;


            //collectionToZoneToPosition[listCollectionsUser[i]][zone] = removeIndexElement(collectionToZoneToPosition[listCollectionsUser[i]][zone], positionIndex);

        }

        //Position[] memory positionsCollect1 = collectionToZoneToPosition[listCollectionsUser[0]][zone];
        //Position[] memory positionsCollect2;
        //Position[] memory positionsCollect3;
        //uint256 positionIndex1 = getPositionInArray(positionsCollect1, msg.sender);
        //uint256 positionIndex2;
        //uint256 positionIndex3;

        //if(listCollectionsUser.length > 1) {
        //    positionsCollect2 = collectionToZoneToPosition[listCollectionsUser[1]][zone];
        //    positionIndex2 = getPositionInArray(positionsCollect2, msg.sender);
        //    collectionToZoneToPosition[listCollectionsUser[1]][zone] = removeIndexElement(positionsCollect2, positionIndex2);
        //}
        //if(listCollectionsUser.length > 2) {
        //    positionsCollect3 = collectionToZoneToPosition[listCollectionsUser[2]][zone];
        //    positionIndex3 = getPositionInArray(positionsCollect3, msg.sender);
        //    collectionToZoneToPosition[listCollectionsUser[2]][zone] = removeIndexElement(positionsCollect3, positionIndex3);
        //}

        //collectionToZoneToPosition[listCollectionsUser[0]][zone] = removeIndexElement(positionsCollect1, positionIndex1);

        active[msg.sender] = false;
    }

}
