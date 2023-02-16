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
