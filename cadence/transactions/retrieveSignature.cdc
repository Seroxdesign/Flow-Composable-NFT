// This transaction is used to retrieve a signature from an NFT stored in the signer's account.
//
// The NFT is retrieved from storage and the getSignature function is called on it with the signature id.
//
// The retrieved signature is then stored in the signer's account.

import ComposableNFT from "./contracts/ComposableNFT.cdc"
import NFTSignature from "./contracts/NFTSignature.cdc"

transaction(signatureId: UInt64) {
    let signature: @NFTSignature.Signature

    prepare(account: AuthAccount) {
        let nft = account.borrow<&ComposableNFT.NFT>(from: /storage/NFT)
            ?? panic("No NFT in storage")
        self.signature <- nft.getSignature(signatureId: signatureId) 
            ?? panic("No signature with this id")
    }

    commit {
        getAccount(0x01).save<@NFTSignature.Signature>(<-self.signature, to: /storage/Signature)
    }
}