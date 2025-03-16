const Pipi = artifacts.require("Pipi");

contract("Pipi", (accounts) => {
  const [owner, addr1, addr2] = accounts;

  let pipi;

  beforeEach(async () => {
    pipi = await Pipi.new("PipiNFT", "PIPI");
  });

  it("should return the correct name and symbol", async () => {
    const name = await pipi.name();
    const symbol = await pipi.symbol();
    assert.equal(name, "PipiNFT");
    assert.equal(symbol, "PIPI");
  });

  it("should mint and transfer an NFT", async () => {
    await pipi.mint(addr1, 1);
    let ownerOfToken = await pipi.ownerOf(1);
    assert.equal(ownerOfToken, addr1);

    await pipi.transferFrom(addr1, addr2, 1, { from: addr1 });
    ownerOfToken = await pipi.ownerOf(1);
    assert.equal(ownerOfToken, addr2);
  });

  it("should set and get token URI", async () => {
    await pipi.mint(addr1, 1);
    await pipi.setTokenURI(1, "https://img0.baidu.com/it/u=774708085,3170430767&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1067", { from: addr1 });
    const tokenURI = await pipi.tokenURI(1);
    assert.equal(tokenURI, "https://img0.baidu.com/it/u=774708085,3170430767&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1067");
  });

  it("should return the correct balance of NFTs for an address", async () => {
    await pipi.mint(addr1, 1);
    await pipi.mint(addr1, 2);
    const balance = await pipi.balanceOf(addr1);
    assert.equal(balance.toNumber(), 2);
  });
});