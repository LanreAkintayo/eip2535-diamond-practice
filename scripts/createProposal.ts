import { ethers } from "hardhat";
import {toWei, fromWei, now, sDuration, fastForwardTheTime} from "../utils/helper"

interface Option {
    index:number,
    optionText:string,
    vote:number
}

async function createProposal() {
    // const dao = await ethers.getContract("Dao")
   const diamond = await ethers.getContract('Diamond')

    const dao = await ethers.getContractAt('IDaoFacet', diamond.address)

    const lar = await ethers.getContract("LAR")

    const title = "Testing Quadratic Voting"
    const description = "Will the quadratic mechanism work in a single try?"
    const proposalType = 2
    const proposalStatus = 0
    const startDate = await now()
    const duration = sDuration.hours(48)
    const options: Option[] =  [{
            index: 0,
            optionText:"I doubt it will work",
            vote: 0
        }, {
            index: 1,
            optionText:"It will certainly work",
            vote: 0
        },
        {
            index: 2,
            optionText:"It will never work ",
            vote: 0
        }
    ]

    const approveTx = await lar.approve(dao.address, toWei(200))
    await approveTx.wait(1);

    console.log("Creating a proposal.....")

    const createTx = await dao.createProposal(
        title,
        description,
        proposalType,
        proposalStatus,
        startDate,
        duration,
        options
    )
    await createTx.wait(1)

    console.log("Proposal created.....")
}



createProposal().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });