// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorage.sol";

contract DaoFacet2 is ReentrancyGuard {
    AppStorage internal s;
    
    event VoteCreated(
        uint id,
        uint[] optionVotes,
        uint[] optionIndexes,
        address voterAddress,
        Option[] proposalOptions
    );

    event Vote(uint256 id, Voter voter, Option[] options);

    function voteProposalBySingleChoice(
        uint256 id,
        uint256 index,
        uint256 votingPower
    ) external nonReentrant {
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(
            proposal.proposalType == ProposalType.SingleChoice,
            "single choice voting not allowed"
        );

        require(
            block.timestamp < proposal.startDate + proposal.duration,
            "Proposal closed"
        );
        require(hasVoted < 0, "Voted already");
        require(
            s.larToken.balanceOf(msg.sender) >= votingPower,
            "Insufficient VP"
        );

        s.larToken.transferFrom(msg.sender, address(this), votingPower);

        s.proposals[id].options[index].vote += votingPower;

        uint[] memory optionIndex = new uint[](1);
        optionIndex[0] = index;

        uint[] memory optionVotes = new uint[](1);
        optionVotes[0] = votingPower;

        Voter memory voter = Voter({
            voterAddress: msg.sender,
            optionIndexes: optionIndex,
            optionVotes: optionVotes
        });

        s.proposals[id].voters.push(voter);

        // Update proposalsArray
        int proposalIndex = getProposalIndex(id, s.proposalsArray);
        require(
            proposalIndex != -1,
            "Proposal cannot be found"
        );

        delete s.proposalsArray[uint(proposalIndex)];

        s.proposalsArray[uint(proposalIndex)] = s.proposals[id];

        emit Vote(id, voter, s.proposals[id].options);
        emit VoteCreated(
            id,
            optionVotes,
            optionIndex,
            msg.sender,
            s.proposals[id].options
        );
    }

    function voteProposalByWeighing(
        uint256 id,
        uint256[] memory indexes,
        uint256[] memory votingPower
    ) external nonReentrant {
        uint256 totalVotingPower = getTotalVotingPower(votingPower);
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(
            proposal.proposalType == ProposalType.Weighted,
            "weighted voting not allowed"
        );

        require(
            block.timestamp < proposal.startDate + proposal.duration,
            "Proposal closed"
        );
        require(hasVoted < 0, "Voted already");
        require(
            s.larToken.balanceOf(msg.sender) >= totalVotingPower,
            "Insufficient VP"
        );
        s.larToken.transferFrom(msg.sender, address(this), totalVotingPower);

        Option[] storage options = s.proposals[id].options;

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 currentOptionIndex = indexes[i];
            uint256 currentOptionVotingPower = votingPower[i];
            options[currentOptionIndex].vote += currentOptionVotingPower;
        }

        // Voter[] voters = proposal.voters
        Voter memory voter = Voter({
            voterAddress: msg.sender,
            optionIndexes: indexes,
            optionVotes: votingPower
        });

        s.proposals[id].voters.push(voter);

        // Update proposalsArray
        int proposalIndex = getProposalIndex(id, s.proposalsArray);
        require(
            proposalIndex != -1,
            "Proposal cannot be found"
        );

        delete s.proposalsArray[uint(proposalIndex)];

        s.proposalsArray[uint(proposalIndex)] = s.proposals[id];

        emit Vote(id, voter, options);
        emit VoteCreated(
            id,
            votingPower,
            indexes,
            msg.sender,
            s.proposals[id].options
        );
    }

     function getProposalIndex(
        uint id,
        Proposal[] memory proposalsArray
    ) public pure returns (int256) {
        for (uint i = 0; i < proposalsArray.length; i++) {
            Proposal memory currentProposal = proposalsArray[i];
            if (currentProposal.id == id) {
                return int(i);
            }
        }
        return -1;
    }

    function getTotalVotingPower(
        uint256[] memory votingPower
    ) internal pure returns (uint256 totalVotingPower) {
        for (uint256 i = 0; i < votingPower.length; i++) {
            totalVotingPower += votingPower[i];
        }
    }

    function checkVotingStatus(
        uint256 id,
        address voter
    ) public view returns (int256) {
        Voter[] memory voters = s.proposals[id].voters;
        for (uint256 i = 0; i < voters.length; i++) {
            address currentVoter = voters[i].voterAddress;
            if (voter == currentVoter) {
                return int256(i);
            }
        }
        return -1;
    }

    function getProposalsArray() external view returns (Proposal[] memory) {
        return s.proposalsArray;
    }
}
