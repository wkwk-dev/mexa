// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

contract mockFaucet{
    
    function payUp(address payable to,uint256 amount) external{
        to.transfer(amount);
    }

    receive() external payable {}
}