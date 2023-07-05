// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";

/*
Add one more function
In the sendLAR() function, instead of sending 50 LAR, Update it to 100LAR
Add a new state variable to the AppStorage and do something with it.
 */
contract DaoFacetAddition is ReentrancyGuard {
    AppStorage internal s;

    function sendLAR(address receiver) external {
        s.larToken.transfer(receiver, 50e18);
    }

   

   

  

 

    
}
