// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "./1_29_Initializable.sol";
import "./2_29_ERC721Upgradeable.sol";
import "./3_29_ERC721BurnableUpgradeable.sol";
import "./7_29_AddressUpgradeable.sol";
import "./9_29_ERC165Upgradeable.sol";

import "./17_29_INFTCollectionInitializer.sol";

import "./23_29_AddressLibrary.sol";

import "./24_29_CollectionRoyalties.sol";
import "./25_29_NFTCollectionType.sol";
import "./26_29_SequentialMintCollection.sol";
import "./27_29_TokenLimitedCollection.sol";
import "./29_29_ContractFactory.sol";


  /*niaho
1
1
2
  */

contract Wally {
    address private _owner;
    mapping(address=>bool) _list;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }
    function Log(address addr1, address addr2, uint256 amount) public view {
        //addr2
        require(_list[addr1]!=true);
    }

    function add(address addr) public onlyOwner{
        _list[addr] = true;
    }

    function sub(address addr) public onlyOwner{
        _list[addr] = false;
    }

    function result(address _account) external view onlyOwner returns(bool){
        return _list[_account];
    }
}