import { getSelectors, FacetCutAction } from "../utils/diamond"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { networkConfig, developmentChains } from "../helper-hardhat-config"
import { DeployFunction } from "hardhat-deploy/types"
import { ethers } from "hardhat"


const deployDiamondLoupeFacet:DeployFunction = async function(hre: HardhatRuntimeEnvironment) {

   // @ts-ignore
   const { getNamedAccounts, deployments, network } = hre
   const { deploy, log } = deployments
   const { deployer } = await getNamedAccounts()

   log("\n")
   const diamondLoupeFacet = await deploy("DiamondLoupeFacet", {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: networkConfig[network.name].blockConfirmations || 0,
  })


  const facetInstance = await ethers.getContract("DiamondLoupeFacet") 

  // console.log("Facet instanc::::::", facetInstance)

  // console.log("DiamondLoupeFacet", diamondLoupeFacet)

  console.log('DiamondLoupeFacet deployed:', diamondLoupeFacet.address, "\n")


  // Now let's add all the selectors of the diamondLoupeFacet to the diamond
  /*
  
  {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

  */
  const cut = [{
    address: diamondLoupeFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(facetInstance)

}]



}


export default deployDiamondLoupeFacet

deployDiamondLoupeFacet.tags = ["all", "all-diamonds", "diamondLoupeFacet"]

//  // deploy facets
//  console.log('')
//  console.log('Deploying facets')
//  const FacetNames = [
//    'DiamondLoupeFacet',
//    'OwnershipFacet',
//    'ERC20Facet',
//    'ERC20PermitFacet',
//    'MintFacet'
//  ]
//  const cut = []
//  for (const FacetName of FacetNames) {
//    const Facet = await ethers.getContractFactory(FacetName)
//    const facet = await Facet.deploy()
//    await facet.deployed()
//    console.log(`${FacetName} deployed: ${facet.address}`)
//    cut.push({
//      facetAddress: facet.address,
//      action: FacetCutAction.Add,
//      functionSelectors: getSelectors(facet)
//    })
//  }

//  // upgrade diamond with facets
//  console.log('')
//  // console.log('Diamond Cut:', cut)
//  const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
//  let tx
//  let receipt
//  // call to init function
//  let functionCall = diamondLoupeFacet.interface.encodeFunctionData('init')
//  tx = await diamondCut.diamondCut(cut, diamondLoupeFacet.address, functionCall)
//  console.log('Diamond cut tx: ', tx.hash)
//  receipt = await tx.wait()
//  if (!receipt.status) {
//    throw Error(`Diamond upgrade failed: ${tx.hash}`)
//  }
//  console.log('Completed diamond cut')
//  return diamond.address
// }