import { useState, useEffect } from 'react';
import './flowConfig';
import * as fcl from "@onflow/fcl";
import { getEnvironment } from "@onflow/flow-cadut";
import { getNFTsFromAccount } from './cadut/scripts';
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
