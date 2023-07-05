// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import {AppStorage, ProposalType, ProposalStatus, Option, Voter, Proposal} from "../libraries/LibAppStorage.sol";

/*
createQuadraticProposal()
createWeightedProposal()
createSingleChoiceProposal()
voteByQuadratic()
voteBySingleChoice()
voteByWeighted()

 */
contract DaoFacet is ReentrancyGuard {
    AppStorage internal s;

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

        s.proposalId++;

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

    function voteProposalByQuadratic(
        uint256 id,
        uint256[] memory indexes,
        uint256[] memory votingPower
    ) external nonReentrant {
        uint256 totalVotingPower = getTotalVotingPower(votingPower);
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(proposal.proposalType == ProposalType.Quadratic, "quadratic voting not allowed for the proposal");

        require(
            block.timestamp < proposal.startDate + proposal.duration,
            "Proposal has closed"
        );
        require(hasVoted < 0, "You've voted already");
        require(
            s.larToken.balanceOf(msg.sender) >= totalVotingPower,
            "Insufficient Voting Power"
        );
        s.larToken.transferFrom(msg.sender, address(this), totalVotingPower);

        Option[] storage options = s.proposals[id].options;

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 currentOptionIndex = indexes[i];
            uint256 currentOptionVotingPower = votingPower[i];
            console.log(sqrt(currentOptionVotingPower) * (10**9));
            options[currentOptionIndex].vote += sqrt(currentOptionVotingPower) * (10**9);
        }

        uint[] memory optionVotes = new uint[](votingPower.length);
        for (uint i = 0; i < votingPower.length; i++){
            optionVotes[i] = sqrt(votingPower[i]) * (10**9);
        }

        Voter memory voter = Voter({
            voterAddress: msg.sender,
            optionIndexes: indexes,
            optionVotes: optionVotes
        });

        s.proposals[id].voters.push(voter);

        emit Vote(id, voter, options);
        emit VoteCreated(id, optionVotes, indexes, msg.sender, s.proposals[id].options);

    }

    function voteProposalBySingleChoice(
        uint256 id,
        uint256 index,
        uint256 votingPower
    ) external nonReentrant {
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(proposal.proposalType == ProposalType.SingleChoice, "single choice voting not allowed for the proposal");


        require(
            block.timestamp < proposal.startDate + proposal.duration,
            "Proposal has closed"
        );
        require(hasVoted < 0, "You've voted already");
        require(
            s.larToken.balanceOf(msg.sender) >= votingPower,
            "Insufficient voting Power"
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

        emit Vote(id, voter, s.proposals[id].options);
        emit Testing(id, msg.sender);
        emit VoteCreated(id, optionVotes, optionIndex, msg.sender, s.proposals[id].options);
        // s.proposals[id].voters.push(msg.sender);
    }

    function voteProposalByWeighing(
        uint256 id,
        uint256[] memory indexes,
        uint256[] memory votingPower
    ) external nonReentrant {
        uint256 totalVotingPower = getTotalVotingPower(votingPower);
        int256 hasVoted = checkVotingStatus(id, msg.sender);
        Proposal memory proposal = s.proposals[id];

        require(proposal.proposalType == ProposalType.Weighted, "weighted voting not allowed for the proposal");

        require(
            block.timestamp < proposal.startDate + proposal.duration,
            "Proposal has closed"
        );
        require(hasVoted < 0, "You've voted already");
        require(
            s.larToken.balanceOf(msg.sender) >= totalVotingPower,
            "Insufficient Voting Power"
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
        

        emit Vote(id, voter, options);
        emit VoteCreated(id, votingPower, indexes, msg.sender, s.proposals[id].options); 

    }

    function getTotalVotingPower(uint256[] memory votingPower)
        internal
        pure
        returns (uint256 totalVotingPower)
    {
        for (uint256 i = 0; i < votingPower.length; i++) {
            totalVotingPower += votingPower[i];
        }
    }

    function checkVotingStatus(uint256 id, address voter)
        public
        view
        returns (int256)
    {
        Voter[] memory voters = s.proposals[id].voters;
        for (uint256 i = 0; i < voters.length; i++) {
            address currentVoter = voters[i].voterAddress;
            if (voter == currentVoter) {
                return int256(i);
            }
        }
        return -1;
    }

    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function getProposals(uint256 proposalId) external view returns(Proposal memory){
        return s.proposals[proposalId];
    }

    
}
