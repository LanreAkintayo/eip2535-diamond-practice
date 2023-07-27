//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



    enum ProposalType {
        SingleChoice,
        Weighted,
        Quadratic
    }

    enum ProposalStatus {
        Pending,
        Active,
        Closed
    }

    struct Option {
        uint256 index;
        string optionText;
        uint256 vote;
    }

    struct Voter {
        address voterAddress;
        uint[] optionIndexes;
        uint[] optionVotes;
    }


/*
    export interface Proposal {
        id: string;
        creator: string;
        description: string;
        duration: number;
        proposalStatus: string;
        proposalType: string;
        latestOptions: string[][] | undefined;
        startDate: number;
        endDate: number;
        status: string;
        timeLeft: number;
        title: string;
        optionsArray: {
            optionIndex: string;
            optionText: string;
            optionVote: string;
            optionPercentage: string;
        }[];
        validOptions: string[][];

    }

*/
    struct Proposal {
        uint256 id;
        address creator;
        string title;
        string description;
        ProposalType proposalType;
        ProposalStatus proposalStatus;
        uint256 startDate;
        uint256 duration;
        Option[] options;
        Voter[] voters;
    }

    /*
    
  proposal1 = {
      latestOptions: [[optionIndex1, optionText1, optionVote1, optionPercentage1], [optionIndex2, optionText2, optionVote2, optionPercentage2]]
      optionsArray: [[optionIndex1, optionText1, optionVote1, optionPercentage1], [optionIndex2, optionText2, optionVote2, optionPercentage2]]
      validOptions: [[optionIndex1, optionText1, optionVote1, optionPercentage1], [optionIndex2, optionText2, optionVote2, optionPercentage2]]


  allProposals = [proposal1, proposal2, proposal3, e.t.c.]
  
  }



  Whenever someone votes, the proposalsArray has to be updated. The mapping to has to be updated
    
     */


    
struct AppStorage {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => Counters.Counter) nonces;  

    IERC20 larToken;
    uint256 proposalId;

    mapping(uint256 => Proposal) proposals;

    uint256[] proposalsList;

    Proposal[] proposalsArray;

    uint256[] proposalsId;

}

library LibAppStorage {
    // diamondStorage() returns the position of the App storage struct in the diamond contract
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }


    function sqrt(uint256 y) internal pure returns (uint256 z) {
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
}