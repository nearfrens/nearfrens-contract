// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

//TODO: add status + future check-in (fonction séparée) + add fct to get the addressToPosition mapping.

contract NearFrens {
    
    ///here we add the user in order to be able to track it's position in arrays to remove it.
    struct Position {
        int32 latitude;
        int32 longitude;
        uint256 timestamp;
        address user;
        string status;
    }

    struct LastCheckInData {
        Position _position;
        address[] _collections;
        uint256 _zone;
        string status;
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
        uint256[] memory _tokenIDs,
        string memory _status) external {

        require(_collections.length < 4, "Check in max for 3 collections");
        require(bytes(_status).length < 128, "too long description");
    
        //for(uint j = 0; j < _tokenIDs.length; j++) {
        //    require(IERC721(_collections[j]).ownerOf(_tokenIDs[j]) == msg.sender);
        //}
        
        if(active[msg.sender] == true) {
            checkOut();
        }
        
        Position storage p = addressToPosition[msg.sender].push();
        p.latitude = _latitude;
        p.longitude = _longitude;
        p.timestamp = block.timestamp;
        p.user = msg.sender;
        p.status = _status;
        
        
        for(uint i = 0; i < _collections.length; i++) {
            require(collectionToZoneToPosition[_collections[i]][_zoneID].length < 10000, "too much users checked in for this collection in this zone");
            collectionToZoneToPosition[_collections[i]][_zoneID].push(p);

        }
        

        LastCheckInData memory checkInData = LastCheckInData(p, _collections, _zoneID, _status);
        addressToLastCheckInData[msg.sender] = checkInData;
        active[msg.sender] = true;
    }

    /// @dev This function locates the data of the user in the array: collectionToZoneToPosition
    ///       once located this data is removed by switching item index with last position and deleting last position.
    /// ToDo Optimize with for loop and use arrays for positionsIndex1,2,3...  
     function checkOut() internal {
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
            newArr.pop();
            collectionToZoneToPosition[listCollectionsUser[i]][zone] = newArr;

        }

    }

    function getListOfUserPositions(address user) external view returns (Position[] memory positions) {
        Position[] memory p;
        for(uint256 i = 0; i < addressToPosition[user].length; i++) {
            p[i] = addressToPosition[user][i];
        }
        return p;
    }

}
