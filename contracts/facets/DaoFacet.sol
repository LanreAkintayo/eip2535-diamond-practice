// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/LibDiamond.sol";

import "hardhat/console.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";

contract DaoFacet is ReentrancyGuard {
    AppStorage internal s;
    // DiamondStorage internal d;

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

    function initializeDao(address larTokenAddress) external {
        s.larToken = IERC20(larTokenAddress);
    }

    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _proposalType,
        uint256 _proposalStatus,
        uint256 _startDate,
        uint256 _duration,
        Option[] memory _options
    ) external nonReentrant {
        require(
            s.larToken.balanceOf(msg.sender) >= 5e18,
            "Minimum of 5 LAR is needed to create a proposal"
        );

        s.larToken.transferFrom(msg.sender, address(this), 5e18);

        ProposalType proposalType;
        if (_proposalType == 0) {
            proposalType = ProposalType.SingleChoice;
        } else if (_proposalType == 1) {
            proposalType = ProposalType.Weighted;
        } else if (_proposalType == 2) {
            proposalType = ProposalType.Quadratic;
        }

        ProposalStatus proposalStatus;
        if (_proposalStatus == 0) {
            proposalStatus = ProposalStatus.Pending;
        } else if (_proposalStatus == 1) {
            proposalStatus = ProposalStatus.Active;
        } else if (_proposalStatus == 2) {
            proposalStatus = ProposalStatus.Closed;
        }

        Proposal storage proposal = s.proposals[s.proposalId];
        proposal.id = s.proposalId;
        proposal.creator = msg.sender;
        proposal.title = _title;
        proposal.description = _description;
        proposal.proposalType = proposalType;
        proposal.proposalStatus = proposalStatus;
        proposal.startDate = _startDate;
        proposal.duration = _duration;

        for (uint256 i = 0; i < _options.length; i++) {
            Option memory currentOption = _options[i];
            // console.log("This is the current option: ", currentOption.optionText);
            proposal.options.push(currentOption);
        }

        // Push to proposalsArray
        s.proposalsArray.push(proposal);

        // Push to proposalsId
        s.proposalsId.push(s.proposalId);

        s.proposalId++;

        emit ProposalCreated(
            s.proposalId,
            msg.sender,
            _title,
            _description,
            proposalType,
            proposalStatus,
            _startDate,
            _duration,
            _options
        );
    }

    function getOptions(uint256 id) external view returns (Option[] memory) {
        return s.proposals[id].options;
    }

    function getVoters(uint256 id) external view returns (Voter[] memory) {
        return s.proposals[id].voters;
    }

    function sendLAR(address receiver) external {
        s.larToken.transfer(receiver, 50e18);
    }

    function getProposals(
        uint256 proposalId
    ) external view returns (Proposal memory) {
        return s.proposals[proposalId];
    }

    function getProposalsId() external view returns (uint256[] memory) {
        return s.proposalsId;
    }

    function deletePreviousData() external {
        require(
            msg.sender == LibDiamond.diamondStorage().contractOwner,
            "Only owner can delete"
        );
        for (uint i = 0; i < s.proposalId; i++) {
            delete s.proposals[i];
        }
        delete s.proposalsArray;
        s.proposalId = 0;
    }
}
