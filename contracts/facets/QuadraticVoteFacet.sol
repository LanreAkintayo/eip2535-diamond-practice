// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorage.sol";

contract QuadraticVoteFacet is ReentrancyGuard {
    AppStorage internal s;

    event VoteCreated(
        uint id,
        uint[] optionVotes,
        uint[] optionIndexes,
        address voterAddress,
        Option[] proposalOptions
    );

    event Vote(uint256 id, Voter voter, Option[] options);

    function voteProposalByQuadratic(
            uint256 id,
            uint256[] memory indexes,
            uint256[] memory votingPower
    ) external nonReentrant {
        uint256 totalVotingPower = getTotalVotingPower(votingPower);
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(
            proposal.proposalType == ProposalType.Quadratic,
            "quadratic voting not allowed"
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

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 currentOptionIndex = indexes[i];
            uint256 currentOptionVotingPower = votingPower[i];
            console.log(LibAppStorage.sqrt(currentOptionVotingPower) * (10 ** 9));
            s.proposals[id].options[currentOptionIndex].vote +=
                LibAppStorage.sqrt(currentOptionVotingPower) *
                (10 ** 9);
        }

        uint[] memory optionVotes = new uint[](votingPower.length);
        for (uint i = 0; i < votingPower.length; i++) {
            optionVotes[i] = LibAppStorage.sqrt(votingPower[i]) * (10 ** 9);
        }

        Voter memory voter = Voter({
            voterAddress: msg.sender,
            optionIndexes: indexes,
            optionVotes: optionVotes
        });

        s.proposals[id].voters.push(voter);

        // Update proposalsArray
        int index = getProposalIndex(id, s.proposalsArray);
        require(index != -1, "Proposal cannot be found");

        delete s.proposalsArray[uint(index)];

        s.proposalsArray[uint(index)] = s.proposals[id];

        emit Vote(id, voter, s.proposals[id].options);
        emit VoteCreated(
            id,
            optionVotes,
            indexes,
            msg.sender,
            s.proposals[id].options
        );
    }


    function getTotalVotingPower(
        uint256[] memory votingPower
    ) internal pure returns (uint256 totalVotingPower) {
        for (uint256 i = 0; i < votingPower.length; i++) {
            totalVotingPower += votingPower[i];
        }
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

}
