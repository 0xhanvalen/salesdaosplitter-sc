// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../Interfaces/Splitter.sol";
import "./Splitter.sol";

contract SplitterFactory {
    mapping(address => Splitter) public deployedSplittersbyRecipient;
    mapping(address => address) public splittersAddressesByRecipient;
    address public _daoTreasuryAddress;
    address public _daoSignerAddress;
    address public _owner;

    // constructor() {
    //     _daoTreasuryAddress = 0xef107eEf75a2efaa93a21500524A79904A0a5Cf7;
    //     _daoSignerAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    //     _owner = msg.sender;
    // }

    constructor(address daoTreasury, address daoSigner) {
        _daoTreasuryAddress = daoTreasury;
        _daoSignerAddress = daoSigner;
        _owner = msg.sender;
    }

    mapping(address => bool) public _daoMembers;

    function createSplit(address recipient) public {
        require(
            _daoMembers[msg.sender] == true || msg.sender == _owner,
            "Only DAO members can create splits"
        );
        Splitter newSplit = new Splitter(recipient, _daoTreasuryAddress);
        deployedSplittersbyRecipient[recipient] = newSplit;
        splittersAddressesByRecipient[recipient] = address(newSplit);
        _daoMembers[recipient] = true;
    }

    function removeDAOMember(address member) public {
        require(
            msg.sender == _daoSignerAddress || msg.sender == _owner,
            "Only DAO or owner can remove members"
        );
        _daoMembers[member] = false;
    }

    function withdrawDai(address recipient) public {
        Splitter splitter = deployedSplittersbyRecipient[recipient];
        splitter.withdrawDai();
    }

    function withdrawEth(address recipient) public {
        Splitter splitter = deployedSplittersbyRecipient[recipient];
        splitter.withdrawEth();
    }
}
