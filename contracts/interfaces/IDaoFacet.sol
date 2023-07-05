// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";

/*
createQuadraticProposal()
createWeightedProposal()
createSingleChoiceProposal()
voteByQuadratic()
voteBySingleChoice()
voteByWeighted()

 */
interface IDaoFacet{
   
    event ProposalCreated(
        uint256 id,
        address creator,
        string title,
        string description,
        ProposalType proposalType,
        ProposalStatus proposalStatus,
        uint256 startDate,
        uint256 duration,
        Option[] options
    );


    event VoteCreated(uint id, uint[] optionVotes, uint[] optionIndexes, address voterAddress, Option[] proposalOptions);

    event Vote(uint256 id, Voter voter, Option[] options);
    event Testing(uint256 id, address voter);


    function initializeDao(address larTokenAddress) external;

    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _proposalType,
        uint256 _proposalStatus,
        uint256 _startDate,
        uint256 _duration,
        Option[] memory _options
    ) external ;

    function getOptions(uint256 id) external view returns (Option[] memory) ;

    function getVoters(uint256 id) external view returns (Voter[] memory) ;

    function sendLAR(address receiver) external ;

    function voteProposalByQuadratic(
        uint256 id,
        uint256[] memory indexes,
        uint256[] memory votingPower
    ) external ;

    function voteProposalBySingleChoice(
        uint256 id,
        uint256 index,
        uint256 votingPower
    ) external ;

    function voteProposalByWeighing(
        uint256 id,
        uint256[] memory indexes,
        uint256[] memory votingPower
    ) external ;
  

    function checkVotingStatus(uint256 id, address voter)
        external
        view
        returns (int256)
    ;

    function sqrt(uint256 y) external pure returns (uint256 z);

    function getProposals(uint256 proposalId) external view returns(Proposal memory);
    
    function updateProposalList(uint256 proposalId) external;

    function getProposalsList() external view returns(uint256[] memory);

    
}
