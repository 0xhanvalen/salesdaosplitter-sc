// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Splitter {
    IERC20 DAI;
    address public owner;
    address public _recipient;
    address public _daoAddress;
    address _daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 public _heldDai;
    uint256 public _heldEth;

    event PaymentReceived(address from, uint256 amount);
    event PayoutCompleted(address to, uint256 amount);

    constructor(address recipient, address daoAddress) {
        DAI = IERC20(_daiAddress);
        owner = msg.sender;
        _recipient = recipient;
        _daoAddress = daoAddress;
    }

    function payWithEth() external payable {
        _heldEth += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
        // split incoming dai to dao and recipient 10/90
        uint256 daoAmount = msg.value / 10;
        uint256 recipientAmount = msg.value - daoAmount;
        bool recipientPayout = payable(_recipient).send(recipientAmount);
        require(recipientPayout, "recipient payout failed");
        _heldEth -= recipientAmount;
        emit PayoutCompleted(_recipient, recipientAmount);
        bool daoPayout = payable(_daoAddress).send(daoAmount);
        require(daoPayout, "dao payout failed");
        _heldEth -= daoAmount;
        emit PayoutCompleted(_daoAddress, daoAmount);
    }

    function payWithDai(uint256 daiAmount) external {
        bool success = DAI.transferFrom(msg.sender, address(this), daiAmount);
        require(success, "payment failed");
        _heldDai += daiAmount;
        emit PaymentReceived(msg.sender, daiAmount);
        // split incoming dai to dao and recipient 10/90
        uint256 daoAmount = daiAmount / 10;
        uint256 recipientAmount = daiAmount - daoAmount;
        bool recipientPayout = DAI.transfer(_recipient, recipientAmount);
        require(recipientPayout, "recipient payout failed");
        _heldDai -= recipientAmount;
        emit PayoutCompleted(_recipient, recipientAmount);
        bool daoPayout = DAI.transfer(_daoAddress, daoAmount);
        require(daoPayout, "dao payout failed");
        _heldDai -= daoAmount;
        emit PayoutCompleted(_daoAddress, daoAmount);
    }

    function withdrawDai() external {
        require(msg.sender == owner, "only owner can withdraw");
        bool success = DAI.transfer(msg.sender, _heldDai);
        require(success, "withdrawal failed");
    }

    function withdrawEth() external {
        require(msg.sender == owner, "only owner can withdraw");
        bool success = payable(msg.sender).send(_heldEth);
        require(success, "withdrawal failed");
    }
}
