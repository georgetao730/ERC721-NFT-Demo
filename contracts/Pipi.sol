// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IERC721.sol";

contract Pipi is IERC721, IERC165, IERC721Metadata, IERC721Receiver {

    // NFT名称
    string public _contractName;
    // NFT符号
    string public _contractSymbol;
    // tokenId => owner 每个tokenId对应的所有者地址
    mapping(uint256 => address) _owners;
    // address地址 => 拥有的NFT数量 每个地址拥有的NFT数量
    mapping(address => uint256) _balances;
    // tokenId => 授权地址address 每个tokenId对应的授权地址
    mapping(uint256 => address) _tokenApprovals;
    // owner地址 => operator地址的批量授权映射
    mapping(address => mapping(address => bool)) _operatorApprovals;
    // tokenId => tokenURI
    mapping(uint256 => string) _tokenURIs;

    constructor(string memory name1, string memory symbol1) {
        _contractName = name1;
        _contractSymbol = symbol1;
    }

    // 返回NFT的名称
    function name() public view returns (string memory) {
        return _contractName;
    }

    // 返回NFT的符号
    function symbol() public view returns (string memory) {
        return _contractSymbol;
    }

    // 返回指定地址拥有的NFT数量
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Pipi: balance query for the zero address");
        return _balances[owner];
    }

    // 返回指定tokenId的所有者地址
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Pipi: owner query for nonexistent token");
        return owner;
    }

    // 授权指定地址可以转移指定的tokenId
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(to != owner, "Pipi: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Pipi: approve caller is not owner nor approved for all");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 返回指定tokenId的授权地址
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Pipi: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    // 批量授权或取消授权指定操作员地址
    function setApprovalForAll(address operater, bool _approved) public {
        require(msg.sender != operater, "Pipi: approve to caller");
        _operatorApprovals[msg.sender][operater] = _approved;
        emit ApprovalForAll(msg.sender, operater, _approved);
    }

    // 检查指定操作员地址是否被批量授权
    function isApprovedForAll(address owner, address operater) public view returns (bool) {
        return _operatorApprovals[owner][operater];
    }

    // 内部函数，用于授权指定地址可以转移指定的tokenId
    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
    }

    // 内部函数，用于检查指定地址是否有转移指定tokenId的权限
    function _isApprovedOrOwner(address owner, address spender, uint256 tokenId) internal view returns (bool) {
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender] == true);
    }

    // 内部函数，用于转移指定的tokenId
    function _transfer(address owner, address from, address to, uint256 tokenId) internal {
        require(owner == from, "Pipi: transfer of token that is not own");
        require(to != address(0), "Pipi: transfer to the zero address");
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    // 转移指定的tokenId
    function transferFrom(address from, address to,uint256 tokenId) public{
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "Pipi: transfer caller is not owner nor approved");
        _transfer(owner, from, to, tokenId);    
    }

    // 安全转移指定的tokenId，带有数据
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "Pipi: transfer caller is not owner nor approved");
        _safetransfer(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 内部函数，用于安全转移指定的tokenId
    function _safetransfer(address owner, address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Pipi: transfer to non ERC721Receiver implementer");
    }

    // 铸造新的tokenId并分配给指定地址
    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "Pipi: mint to the zero address");
        address owner = _owners[tokenId];
        require(owner == address(0), "Pipi: token already minted");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    // 销毁指定的tokenId
    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "Pipi: caller is not owner nor approved for all");
        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    // 返回指定tokenId的URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Pipi: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    // 设置指定tokenId的URI
    function setTokenURI(uint256 tokenId, string memory uri) public {
        require(_owners[tokenId] != address(0), "Pipi: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    // 检查合约是否支持指定的接口
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId 
                || interfaceId == type(IERC721Metadata).interfaceId 
                || interfaceId == type(IERC165).interfaceId;
    }

    // 内部函数，用于检查接收地址是否实现了onERC721Received方法
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.code.length > 0) {
            return IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    // 实现IERC721Receiver接口，处理接收到的NFT
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}