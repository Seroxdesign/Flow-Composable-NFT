import { useState, useEffect } from 'react';
import './flowConfig';
import * as fcl from "@onflow/fcl";
import { getNFTsFromAccount } from './cadut/scripts';
import { mintNFT } from './cadut/transactions';
import NFTView from './NFTView';

function App() {
  const [user, setUser] = useState({ addr: null, loggedIn: null })
  useEffect(() => { fcl.currentUser().subscribe(setUser) }, [setUser] )

  const [myNFTs, setMyNFTs] = useState([])

  useEffect(() => {
    const run = async () => {
      if (user.loggedIn) {
        const myNFTs = await getNFTsFromAccount({
          args: [fcl.withPrefix(user.addr)],
        });
        setMyNFTs(myNFTs[0])
      }
    }
    run()
  }, [user])

  return (
    <div>
      {user.loggedIn === null && (
        <button onClick={() => { fcl.logIn() }}>Connect Wallet</button>
      )}
      
      {user.loggedIn && (
        <div>
          <button onClick={() => { fcl.unauthenticate() }}>Logout</button>
          <div>Address: {user.addr}</div>
          <button onClick={() => {
            mintNFT({
              args: ["1"], // mint edition 1 from the nft contract,
              signers: [fcl.authz], // Sign the transaction with the fcl authz user
              payer: fcl.authz, // Pay the transaction fee with the fcl authz user
              proposer: fcl.authz // Propose the transaction with the fcl authz user
            })
          }}>
            Mint a new edition 1 NFT
          </button>
          <hr />
          <h3>My NFTs:</h3>
          <div>
            {
              myNFTs.map((curNFT, i) => {
                return <>
                  <h4>NFT {i + 1}</h4>
                  <NFTView { ...curNFT }/>
                </>
              })
            }
          </div>
        </div>
      )}

    </div>
  );
}

export default App;
