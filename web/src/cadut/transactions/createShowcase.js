/** pragma type transaction **/

import {
  getEnvironment,
  replaceImportAddresses,
  reportMissingImports,
  reportMissing,
  sendTransaction
} from '@onflow/flow-cadut'

export const CODE = `
import "Flowcase" from 0xFLOWCASE

transaction(showcaseName: String, accountAddress: Address, publicPaths: [PublicPath], nftIds: [UInt64]) {
    let flowcaseCollection: &Flowcase.ShowcaseCollection

    prepare(signer: AuthAccount) {
        if signer.borrow<&Flowcase.ShowcaseCollection>(from: Flowcase.storagePath) == nil {
            let collection <- Flowcase.createEmptyCollection()
            signer.save(<-collection, to: /storage/flowcaseCollection)
        }

        signer.link<&{Flowcase.ShowcaseCollectionPublic}>(Flowcase.publicPath, target: /storage/flowcaseCollection)

        self.flowcaseCollection = signer.borrow<&Flowcase.Showcase>(from: Flowcase.storagePath) ??
            panic("Could not borrow a reference to the Flowcase")
    }

    execute {
        var showcaseNFTs: [Flowcase.NFTPointer] = []
        let showcaseAccount = getAccount(accountAddress)

        var i = 0
        while (i < publicPaths.length) {
            let publicPath = publicPaths[i]
            let nftId = nftIds[i]
            showcaseNFTs.append(Flowcase.NFTPointer(id: nftId, collection: showcaseAccount.getCapability<&{NonFungibleToken.CollectionPublic}>(publicPath)))
            i++
        }

        self.flowcaseCollection.addShowcase(showcaseName: showcaseName, nfts: showcaseNFTs)
    }
}

`;

/**
* Method to generate cadence code for createShowcase transaction
* @param {Object.<string, string>} addressMap - contract name as a key and address where it's deployed as value
*/
export const createShowcaseTemplate = async (addressMap = {}) => {
  const envMap = await getEnvironment();
  const fullMap = {
  ...envMap,
  ...addressMap,
  };

  // If there are any missing imports in fullMap it will be reported via console
  reportMissingImports(CODE, fullMap, `createShowcase =>`)

  return replaceImportAddresses(CODE, fullMap);
};


/**
* Sends createShowcase transaction to the network
* @param {Object.<string, string>} props.addressMap - contract name as a key and address where it's deployed as value
* @param Array<*> props.args - list of arguments
* @param Array<*> props.signers - list of signers
*/
export const createShowcase = async (props = {}) => {
  const { addressMap, args = [], signers = [] } = props;
  const code = await createShowcaseTemplate(addressMap);

  reportMissing("arguments", args.length, 4, `createShowcase =>`);
  reportMissing("signers", signers.length, 1, `createShowcase =>`);

  return sendTransaction({code, processed: true, ...props})
}