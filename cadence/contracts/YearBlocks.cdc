// YearBlock.cdc
//
// The YearBlocks contract defines two types of NFTs.
// One is a YearBlockSignature, which represents a special hat, and
// the second is the YearBlock resource, which can own YearBlockSignatures Hats.
//
// You can put the YearBlockSignature on the YearBlock and then call a  function
// that tips the hat and prints a fun message.
// 
//
// Learn more about composable resources in this tutorial: https://developers.flow.com/cadence/tutorial/10-resources-compose

pub contract YearBlocks {

    // KittyHat is a special resource type that represents a hat
    pub resource YearBlockSignature {
        pub let id: Int
        pub let name: String
				pub let comment: String

        init(id: Int, name: String, comment: String) {
            self.id = id
            self.name = name
						self.comment = comment
        }

        // An example of a function someone might put in their hat resource
        /* pub fun tipHat(): String {
            if self.name == "Cowboy Hat" {
                return "Howdy Y'all"
            } else if self.name == "Top Hat" {
                return "Greetings, fellow aristocats!"
            } 

            return "Hello"
        } */
    }

    // Create a new Signature
    pub fun signYearBlock(id: Int, name: String, comment: String): @YearBlockSignature {
        return <-create YearBlockSignature(id: id, name: name, comment: comment)
    }

    pub resource YearBlock {

        pub let id: Int

        // place where the Kitty hats are stored
        pub var items: @{String: YearBlockSignature}

        init(newID: Int) {
            self.id = newID
            self.items <- {}
        }

        pub fun getSignatures(): @{String: YearBlockSignature} {
            var other: @{String:YearBlockSignature} <- {}
            self.items <-> other
            return <- other
        }

        pub fun setSignatures(items: @{String: YearBlockSignature}) {
            var other <- items
            self.items <-> other
            destroy other
        }

        pub fun removeSignatures(key: String): @YearBlockSignature? {
            var removed <- self.items.remove(key: key)
            return <- removed
        }

        destroy() {
            destroy self.items
        }
    }

    pub fun createYearBlock(): @YearBlock {
        return <-create YearBlock(newID: 1)
    }
}
