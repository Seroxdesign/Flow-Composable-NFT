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
