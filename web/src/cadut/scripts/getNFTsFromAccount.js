/** pragma type script **/

import {
  getEnvironment,
  replaceImportAddresses,
  reportMissingImports,
  reportMissing,
  executeScript
} from '@onflow/flow-cadut'

export const CODE = `
import NonFungibleToken from 0xNONFUNGIBLETOKENADDRESS
import MetadataViews from 0xMETADATAVIEWSADDRESS

pub fun main(address: Address): [AnyStruct] {
    let account = getAccount(address)
    var nfts: [AnyStruct] = []
    account.forEachPublic(fun (path: PublicPath, type: Type): Bool {

        // Filter for only public NFT collections
        let nftType = Type<Capability<&AnyResource{NonFungibleToken.CollectionPublic}>>()
        if (type.isSubtype(of: nftType)) {
            let nftCollection = account.getCapability<&AnyResource{NonFungibleToken.CollectionPublic}>(path).borrow()!
            let nftIDs = nftCollection.getIDs()!
            for id in nftIDs {
                let nft = nftCollection.borrowNFT(id: id)
                let displayView = nft.resolveView(Type<MetadataViews.Display>())

                nfts.append({
                    "nftID": id,
                    "publicPath": path,
                    "display": displayView,
                    "type": nft.getType().identifier
                })
            }
        }
        return true
    })
    
    return nfts
}

`;

/**
* Method to generate cadence code for getNFTsFromAccount script
* @param {Object.<string, string>} addressMap - contract name as a key and address where it's deployed as value
*/
export const getNFTsFromAccountTemplate = async (addressMap = {}) => {
  const envMap = await getEnvironment();
  const fullMap = {
  ...envMap,
  ...addressMap,
  };

  // If there are any missing imports in fullMap it will be reported via console
  reportMissingImports(CODE, fullMap, `getNFTsFromAccount =>`)

  return replaceImportAddresses(CODE, fullMap);
};

export const getNFTsFromAccount = async (props = {}) => {
  const { addressMap = {}, args = [] } = props
  const code = await getNFTsFromAccountTemplate(addressMap);

  reportMissing("arguments", args.length, 1, `getNFTsFromAccount =>`);

  return executeScript({code, processed: true, ...props})
}