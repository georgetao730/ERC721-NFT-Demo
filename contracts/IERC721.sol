// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IERC721 {

    // 交易
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 授权
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 授权所有
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // 查询指定地址拥有的NFT数量    
    function balanceOf(address owner) external view returns (uint256 balance);

    // 查询指定NFT的拥有者
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // 用于将一个NFT从一个地址转移到另一个地址。如果接受地址是合约，则必须调用onERC721Received方法 【安全交易】
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    // 用于将一个NFT从一个地址转移到另一个地址 【普通交易】
    function transferFrom(address from, address to, uint256 tokenId) external;

    // 用于授权一个地址可以转移指定NFT 【授权】
    function approve(address to, uint256 tokenId) external;

    // 查询指定NFT的授权地址
    function getApproved(uint256 tokenId) external view returns (address operator);

    // 用于授权一个地址可以转移指定地址的所有NFT 【授权所有】
    function setApprovalForAll(address operator, bool _approved) external;

    // 查询一个操作者是否被授权可以转移指定地址的所有NFT的权限
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Metadata {

    // 查询NFT的名称
    function name() external view returns (string memory);

    // 查询NFT的符号
    function symbol() external view returns (string memory);

    // 查询NFT的URI
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}   

interface IERC165 {
    
    // 查询是否支持某个接口
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}