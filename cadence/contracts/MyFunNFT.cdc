import "NonFungibleToken"
import "MetadataViews"

pub contract MyFunNFT: NonFungibleToken {

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)image
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, editionID: UInt64, serialNumber: UInt64)
    pub event Burned(id: UInt64)
    pub event EditionCreated(edition: Edition)

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionPrivatePath: PrivatePath

    /// The total number of NFTs that have been minted.
    ///
    pub var totalSupply: UInt64

    /// The total number of  editions that have been created.
    ///
    pub var totalEditions: UInt64


    access(self) let editions: {UInt64: Edition}

    pub struct Metadata {
    
        pub let name: String
        pub let description: String


        init(
            name: String,
            description: String
        ) {
            self.name = name
            self.description = description
        }
    }

    pub struct Edition {

        pub let id: UInt64

        /// The number of NFTs minted in this edition.
        ///
        /// This field is incremented each time a new NFT is minted.
        ///
        pub var size: UInt64


        /// The number of NFTs in this edition that have been burned.
        ///
        /// This field is incremented each time an NFT is burned.
        ///
        pub var burned: UInt64

        pub fun supply(): UInt64 {
            return self.size - self.burned
        }

        /// The metadata for this edition.
        pub let metadata: Metadata

        init(
            id: UInt64,
            metadata: Metadata
        ) {
            self.id = id
            self.metadata = metadata

            self.size = 0
            self.burned = 0

        }

        /// Increment the size of this edition.
        ///
        access(contract) fun incrementSize() {
            self.size = self.size + (1 as UInt64)
        }

        /// Increment the burn count for this edition.
        ///
        access(contract) fun incrementBurned() {
            self.burned = self.burned + (1 as UInt64)
        }
    }

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {

        pub let id: UInt64

        pub let editionID: UInt64
        pub let serialNumber: UInt64

        init(
            editionID: UInt64,
            serialNumber: UInt64
        ) {
            self.id = self.uuid
            self.editionID = editionID
            self.serialNumber = serialNumber
        }

        /// Return the edition that this NFT belongs to.
        ///
        pub fun getEdition(): Edition {
            return MyFunNFT.getEdition(id: self.editionID)!
        }

        pub fun getViews(): [Type] {
            let views = [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Edition>(),
                Type<MetadataViews.Serial>()
            ]

            return views
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            let edition = self.getEdition()
            
            switch view {
                case Type<MetadataViews.Display>():
                    return self.resolveDisplay(edition.metadata)
                case Type<MetadataViews.ExternalURL>():
                    return self.resolveExternalURL()
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return self.resolveNFTCollectionDisplay()
                case Type<MetadataViews.NFTCollectionData>():
                    return self.resolveNFTCollectionData()
                case Type<MetadataViews.Royalties>():
                    return self.resolveRoyalties()
                case Type<MetadataViews.Edition>():
                    return self.resolveEditionView(serialNumber: self.serialNumber, size: edition.size)
                case Type<MetadataViews.Serial>():
                    return self.resolveSerialView(serialNumber: self.serialNumber)
            }

            return nil
        }
        
        pub fun resolveDisplay(_ metadata: Metadata): MetadataViews.Display {
            return MetadataViews.Display(
                name: metadata.name,
                description: metadata.description,
                thumbnail: MetadataViews.HTTPFile(url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/1200px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg"),
            )
        }
        
        pub fun resolveExternalURL(): MetadataViews.ExternalURL {
            let collectionURL = "www.flow-nft-catalog.com"
            return MetadataViews.ExternalURL(collectionURL)
        }
        
        pub fun resolveNFTCollectionDisplay(): MetadataViews.NFTCollectionDisplay {
            let media = MetadataViews.Media(
                file: MetadataViews.HTTPFile(url: "https://assets-global.website-files.com/5f734f4dbd95382f4fdfa0ea/63ce603ae36f46f6bb67e51e_flow-logo.svg"),
                mediaType: "image"
            )
        
            return MetadataViews.NFTCollectionDisplay(
                name: "MyFunNFT",
                description: "The open interopable NFT",
                externalURL: MetadataViews.ExternalURL("www.flow-nft-catalog.com"),
                squareImage: media,
                bannerImage: media,
                socials: {}
            )
        }
        
        pub fun resolveNFTCollectionData(): MetadataViews.NFTCollectionData {
            return MetadataViews.NFTCollectionData(
                storagePath: MyFunNFT.CollectionStoragePath,
                publicPath: MyFunNFT.CollectionPublicPath,
                providerPath: MyFunNFT.CollectionPrivatePath,
                publicCollection: Type<&MyFunNFT.Collection{MyFunNFT.MyFunNFTCollectionPublic}>(),
                publicLinkedType: Type<&MyFunNFT.Collection{MyFunNFT.MyFunNFTCollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
                providerLinkedType: Type<&MyFunNFT.Collection{MyFunNFT.MyFunNFTCollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Provider, MetadataViews.ResolverCollection}>(),
                createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                    return <-MyFunNFT.createEmptyCollection()
                })
            )
        }
        
        pub fun resolveRoyalties(): MetadataViews.Royalties {
            return MetadataViews.Royalties([])
        }
        
        pub fun resolveEditionView(serialNumber: UInt64, size: UInt64): MetadataViews.Edition {
            return MetadataViews.Edition(
                name: "Edition",
                number: serialNumber,
                max: size
            )
        }

        pub fun resolveSerialView(serialNumber: UInt64): MetadataViews.Serial {
            return MetadataViews.Serial(serialNumber)
        }

        destroy() {
            MyFunNFT.totalSupply = MyFunNFT.totalSupply - (1 as UInt64)

            // Update the burn count for the NFT's edition
            let edition = self.getEdition()

            edition.incrementBurned()

            MyFunNFT.editions[edition.id] = edition

            emit Burned(id: self.id)
        }
    }
    

     pub resource interface MyFunNFTCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowMyFunNFT(id: UInt64): &MyFunNFT.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow MyFunNFT reference: The ID of the returned reference is incorrect"
            }
        }
    }
    
    pub resource Collection: MyFunNFTCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        
        /// A dictionary of all NFTs in this collection indexed by ID.
        ///
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
    
        init () {
            self.ownedNFTs <- {}
        }
    
        /// Remove an NFT from the collection and move it to the caller.
        ///
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Requested NFT to withdraw does not exist in this collection")
    
            emit Withdraw(id: token.id, from: self.owner?.address)
    
            return <- token
        }
    
        /// Deposit an NFT into this collection.
        ///
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @MyFunNFT.NFT
    
            let id: UInt64 = token.id
    
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token
    
            emit Deposit(id: id, to: self.owner?.address)
    
            destroy oldToken
        }
    
        /// Return an array of the NFT IDs in this collection.
        ///
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }
    
        /// Return a reference to an NFT in this collection.
        ///
        /// This function panics if the NFT does not exist in this collection.
        ///
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }
    
        /// Return a reference to an NFT in this collection
        /// typed as MyFunNFT.NFT.
        ///
        /// This function returns nil if the NFT does not exist in this collection.
        ///
        pub fun borrowMyFunNFT(id: UInt64): &MyFunNFT.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &MyFunNFT.NFT
            }
    
            return nil
        }
    
        /// Return a reference to an NFT in this collection
        /// typed as MetadataViews.Resolver.
        ///
        /// This function panics if the NFT does not exist in this collection.
        ///
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let nftRef = nft as! &MyFunNFT.NFT
            return nftRef as &AnyResource{MetadataViews.Resolver}
        }
    
        destroy() {
            destroy self.ownedNFTs
        }
    }


    /// Return a public path that is scoped to this contract.
    ///
    pub fun getPublicPath(): PublicPath {
        return PublicPath(identifier: "MyFunNFT_Collection")!
    }

    /// Return a private path that is scoped to this contract.
    ///
    pub fun getPrivatePath(): PrivatePath {
        return PrivatePath(identifier: "MyFunNFT_Collection")!
    }

    /// Return a storage path that is scoped to this contract.
    ///
    pub fun getStoragePath(): StoragePath {
        return StoragePath(identifier: "MyFunNFT_Collection")!
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub fun getEdition(id: UInt64): Edition? {
        return MyFunNFT.editions[id]
    }

    pub fun createEdition(
            name: String,
            description: String,
        ): UInt64 {
            let metadata = Metadata(
                name: name,
                description: description,
            )

            MyFunNFT.totalEditions = MyFunNFT.totalEditions + (1 as UInt64)

            let edition = Edition(
                id: MyFunNFT.totalEditions,
                metadata: metadata
            )

            // Save the edition
            MyFunNFT.editions[edition.id] = edition


            emit EditionCreated(edition: edition) 

            return edition.id
    }

    pub fun mintNFT(editionID: UInt64): @MyFunNFT.NFT {
            let edition = MyFunNFT.editions[editionID]
                ?? panic("edition does not exist")



            // Increase the edition size by one
            edition.incrementSize()

            let nft <- create MyFunNFT.NFT(editionID: editionID, serialNumber: edition.size)

            emit Minted(id: nft.id, editionID: editionID, serialNumber: edition.size)


            // Save the updated edition
            MyFunNFT.editions[editionID] = edition


            MyFunNFT.totalSupply = MyFunNFT.totalSupply + (1 as UInt64)

            return <- nft
    }


    init() {
        self.CollectionPublicPath = MyFunNFT.getPublicPath()
        self.CollectionStoragePath = MyFunNFT.getStoragePath()
        self.CollectionPrivatePath = MyFunNFT.getPrivatePath()

        self.totalSupply = 0
        self.totalEditions = 0

        self.editions = {}

        emit ContractInitialized()
    }
}