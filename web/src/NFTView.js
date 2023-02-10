function NFTView({ display, publicPath, nftID, type }) {
  return (
    <div>
      <div>NFT Title: {display?.name}</div>
      <div>NFT Description: {display?.description}</div>
      <div>NFT ID: {nftID}</div>
      <div>NFT Type: {type}</div>
      <img width={100} height={100} src={display?.thumbnail?.url}/>
    </div>
  );
}

export default NFTView;
