/** pragma type transaction **/

import {
  getEnvironment,
  replaceImportAddresses,
  reportMissingImports,
  reportMissing,
  sendTransaction
} from '@onflow/flow-cadut'

export const CODE = `
import MyFunNFT from 0xMYFUNNFTADDRESS
import MetadataViews from 0xMETADATAVIEWSADDRESS
import NonFungibleToken from 0xNONFUNGIBLETOKENADDRESS

transaction(
    editionID: UInt64,
) {
    let MyFunNFTCollection: &MyFunNFT.Collection{MyFunNFT.MyFunNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}

    prepare(signer: AuthAccount) {
        if signer.borrow<&MyFunNFT.Collection>(from: MyFunNFT.CollectionStoragePath) == nil {
            // Create a new empty collection
            let collection <- MyFunNFT.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: MyFunNFT.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&{NonFungibleToken.CollectionPublic, MyFunNFT.MyFunNFTCollectionPublic, MetadataViews.ResolverCollection}>(
                MyFunNFT.CollectionPublicPath,
                target: MyFunNFT.CollectionStoragePath
            )
        }
        self.MyFunNFTCollection = signer.borrow<&MyFunNFT.Collection{MyFunNFT.MyFunNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(from: MyFunNFT.CollectionStoragePath)!
    }

    execute {
        if (MyFunNFT.totalEditions == 0) {
            MyFunNFT.createEdition(name: "First Edition!", description: "This is the first edition of MyFunNFTs!")
        }
        let item <- MyFunNFT.mintNFT(editionID: 1)
        self.MyFunNFTCollection.deposit(token: <-item)
    }
}

`;

/**
* Method to generate cadence code for mintNFT transaction
* @param {Object.<string, string>} addressMap - contract name as a key and address where it's deployed as value
*/
export const mintNFTTemplate = async (addressMap = {}) => {
  const envMap = await getEnvironment();
  const fullMap = {
  ...envMap,
  ...addressMap,
  };

  // If there are any missing imports in fullMap it will be reported via console
  reportMissingImports(CODE, fullMap, `mintNFT =>`)

  return replaceImportAddresses(CODE, fullMap);
};


/**
* Sends mintNFT transaction to the network
* @param {Object.<string, string>} props.addressMap - contract name as a key and address where it's deployed as value
* @param Array<*> props.args - list of arguments
* @param Array<*> props.signers - list of signers
*/
export const mintNFT = async (props = {}) => {
  const { addressMap, args = [], signers = [] } = props;
  const code = await mintNFTTemplate(addressMap);

  reportMissing("arguments", args.length, 1, `mintNFT =>`);
  reportMissing("signers", signers.length, 1, `mintNFT =>`);

  return sendTransaction({code, processed: true, ...props})
}