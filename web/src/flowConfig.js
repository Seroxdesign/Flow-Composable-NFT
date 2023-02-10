import * as fcl from "@onflow/fcl";
import { setEnvironment, extendEnvironment } from "@onflow/flow-cadut";
import addressMap from "./cadut/addressMap.json";

// Extend the cadut default environment with the addressMap
// which uses cadence-to-json to read all the addresses from
// the flow.json file
let contractNames = Object.keys(addressMap["testnet"]);
for (let index in contractNames) {
    const contractName = contractNames[index];
    extendEnvironment({
        name: contractName,
        testnet: addressMap["testnet"][contractName],
        mainnet: addressMap["mainnet"][contractName],
    });
}

// setup fcl configs to point to the testnet
// Cadut will set the environment to testnet
setEnvironment("testnet")

fcl.config()
  .put("accessNode.api", "https://rest-testnet.onflow.org")
  .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn")


// ------------------------------------------------------------
// Uncomment below to point to mainnet!
// ------------------------------------------------------------
/*
// setup fcl configs to point to the mainnet
setEnvironment("mainnet")
extendEnvironment("mainnet", addressMap["mainnet"])
 fcl.config()
   .put("accessNode.api", "https://rest-mainnet.onflow.org")
   .put("discovery.wallet", "https://fcl-discovery.onflow.org/mainnet/authn")
*/
