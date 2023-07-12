// This transaction is used to create an NFT and store it in the signer's account.
//
// The NFT is created by calling the createNFT function from the ComposableNFT contract.
// The id, link, and allow list for the NFT are passed as arguments to the function.

import ComposableNFT from "../contracts/YearBlocks.cdc"

transaction(id: UInt64, link: String, allowList: [String]) {
    prepare(account: AuthAccount) {
        // Create the NFT and directly save it into the signer's storage
        account.save<@ComposableNFT.NFT>(<-ComposableNFT.createNFT(id: id, link: link, allowList: allowList), to: /storage/NFT)
    }
}