// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IDaoAdditionFacet {

    function sendLAR(address receiver) external;

    function updateProposalList(uint256 proposalId) external;

    function getProposalsList() external view returns(uint256[] memory);
    
}
