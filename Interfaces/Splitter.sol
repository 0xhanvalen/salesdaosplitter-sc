// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISplitter {
    event PaymentReceived(address from, uint256 amount);
    event PayoutCompleted(address to, uint256 amount);

    function withdrawDai() external;

    function withdrawEth() external;

    function payWithEth() external payable;

    function payWithDai(uint256 daiAmount) external;
}
