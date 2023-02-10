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
