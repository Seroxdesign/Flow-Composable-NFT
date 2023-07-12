// This transaction is used to attach a signature to an NFT stored in the signer's account.
//
// The signature is created by calling the createSignature function from the NFTSignature contract.
// The comment, image, and name for the signature are passed as arguments to the function.
//
// The NFT is then retrieved from storage and the addSignature function is called on it with the created signature.

import ComposableNFT from "../contracts/ComposableNFT.cdc"
import NFTSignature from "./contracts/NFTSignature.cdc"

transaction(signatureId: UInt64, comment: String, image: String, name: String) {
    let signature: @NFTSignature.Signature

    prepare(account: AuthAccount) {
        self.signature <- NFTSignature.createSignature(comment: comment, image: image, name: name)
        let nft = account.borrow<&ComposableNFT.NFT>(from: /storage/NFT)
            ?? panic("No NFT in storage")
        nft.addSignature(signatureId: signatureId, signature: <-self.signature)
    }
}