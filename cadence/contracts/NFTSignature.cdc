pub contract NFTSignature {

    // Define the Signature resource
    pub resource Signature {
        pub var digiComment: String
        pub var digiSig: String
        pub var digiName: String

        // Initialize the signature with a comment and an image
        init(comment: String, image: String, name: String) {
            self.digiName = name
            self.digiComment = comment
            self.digiSig = image
        }
    }

    // Function to create a new Signature
    pub fun createSignature(comment: String, image: String, name: String): @Signature {
        return <-create Signature(comment: comment, image: image, name: name)
    }
}