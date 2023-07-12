import NFTSignature from "./NFTSignature.cdc"

pub contract ComposableNFT {

    // Define the base NFT resource
    pub resource NFT {
        pub var id: UInt64
        pub var link: String
        pub var allowList: [String]
        pub var signatures: @{UInt64: NFTSignature.Signature}

        // Initialize the NFT with an ID, a link, and an allow list
        init(id: UInt64, link: String, allowList: [String]) {
            self.id = id
            self.link = link
            self.allowList = allowList
            self.signatures <- {}
        }

        // Function to add a signature to the NFT
        pub fun addSignature(signatureId: UInt64, signature: @NFTSignature.Signature) {
            self.signatures[signatureId] <-! signature
        }

        // Function to get a signature from the NFT
        pub fun getSignature(signatureId: UInt64): @NFTSignature.Signature? {
            let resource: @NFTSignature.Signature? <- self.signatures.remove(key: signatureId)
            return <- resource
        }

        destroy() {
            destroy self.signatures
        }
    }

    pub attachment sig for NFT {
        pub let sigId: UInt64

        init (_ scalarId: UInt64) {
            self.sigId = base.id * scalarId
        }

        pub fun attachSignature(comment: String, image: String, name: String) {
            var signatureResource: @NFTSignature.Signature <- NFTSignature.createSignature(comment: comment, image: image, name: name)
            base.addSignature(signatureId: self.sigId, signature: <- signatureResource)
        }
    }

    // Function to create a new NFT
    pub fun createNFT(id: UInt64, link: String, allowList: [String]): @NFT {
        return <-create NFT(id: id, link: link, allowList: allowList)
    }
}