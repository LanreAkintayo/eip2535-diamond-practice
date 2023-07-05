//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
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

struct AppStorage {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    mapping(address => Counters.Counter) nonces;  

    IERC20 larToken;
    uint256 proposalId;

    mapping(uint256 => Proposal) proposals;

    uint256[] proposalsList;
}

library LibAppStorage {
    // diamondStorage() returns the position of the App storage struct in the diamond contract
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}