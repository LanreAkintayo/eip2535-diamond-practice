import { ethers, getNamedAccounts } from "hardhat";
import {toWei, fromWei, now, sDuration, fastForwardTheTime} from "../utils/helper"

interface Option {
    index:number,
    optionText:string,
    vote:number
}

async function getAllProposals() {
    // const dao = await ethers.getContract("Dao")
    const {deployer} = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)

   const diamond = await ethers.getContract('Diamond')

    const dao = await ethers.getContractAt('IDaoFacet', diamond.target)
    const daoFacet = await ethers.getContract("DaoFacet")
    
    // console.log("Delete Receipt: ", deleteReceipt)


    console.log("Fetching all proposals .....")

    const allProposals = await dao.getProposalsArray()

    // const proposal1 = allProposals[0]

    // console.log("Options: ", proposal1.options)

    console.log("All Proposals.............")
    console.log(allProposals)
}



getAllProposals().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });