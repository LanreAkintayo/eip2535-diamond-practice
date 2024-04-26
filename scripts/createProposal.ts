import { ethers } from "hardhat";
import {toWei, fromWei, now, sDuration, fastForwardTheTime} from "../utils/helper"
import { IDaoFacet, LAR } from "../typechain-types";

interface Option {
    index:number,
    optionText:string,
    vote:number
}

async function createProposal() {
    // const dao = await ethers.getContract("Dao")
   const diamond = await ethers.getContract('Diamond')

    const dao:IDaoFacet = await ethers.getContractAt('IDaoFacet', diamond.target)

    const lar:LAR = await ethers.getContract("LAR")

    const title = "Integration of Cross-Chain Functionality";
    const description =
      "Proposal to explore the integration of cross-chain functionality, enabling interoperability with other blockchain networks.";
    const proposalType = 2
    const proposalStatus = 0
    const startDate = await now()
    const duration = sDuration.hours(48)
    const options: Option[] = [
      {
        index: 0,
        optionText: "Unnecessary",
        vote: 0,
      },
      {
        index: 1,
        optionText: "Improve existing cross-chain capabilities",
        vote: 0,
      },
      {
        index: 2,
        optionText: "Integrate cross-chain functionality",
        vote: 0,
      },
    ];

    const approveTx = await lar.approve(dao.target, toWei(200))
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