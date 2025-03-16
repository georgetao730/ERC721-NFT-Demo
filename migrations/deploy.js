const Pipi = artifacts.require("Pipi");

module.exports = async function (deployer, network, accounts) {
  const [owner] = accounts;

  // 部署合约
  await deployer.deploy(Pipi, "PipiNFT", "PIPI");
  const pipi = await Pipi.deployed();

  // 设置初始的URI
  const initialURIs = [
    "https://img0.baidu.com/it/u=774708085,3170430767&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1067"
  ];

  // 铸造NFT并设置URI
  for (let i = 0; i < initialURIs.length; i++) {
    const tokenId = i + 1;
    await pipi.mint(owner, tokenId);
    await pipi.setTokenURI(tokenId, initialURIs[i]);
  }

  console.log("Pipi contract deployed and initial NFTs minted with URIs set.");
};