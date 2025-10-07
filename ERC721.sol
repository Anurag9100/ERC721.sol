// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Minimal ERC721 (for learning only)
/// @notice Very small ERC721 implementation with mint and tokenURI storage
contract MinimalERC721 {
    string public name;
    string public symbol;
    uint256 private _nextTokenId = 1;
    address public owner;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed ownerAddr, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed ownerAddr, address indexed operator, bool approved);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier exists(uint256 tokenId) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    function balanceOf(address ownerAddr) external view returns (uint256) {
        require(ownerAddr != address(0), "Zero address");
        return _balances[ownerAddr];
    }

    function ownerOf(uint256 tokenId) public view exists(tokenId) returns (address) {
        return _owners[tokenId];
    }

    function tokenURI(uint256 tokenId) external view exists(tokenId) returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function approve(address to, uint256 tokenId) external {
        address tokenOwner = _owners[tokenId];
        require(msg.sender == tokenOwner || _operatorApprovals[tokenOwner][msg.sender], "Not authorized");
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = _owners[tokenId];
        return (spender == tokenOwner || _tokenApprovals[tokenId] == spender || _operatorApprovals[tokenOwner][spender]);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        require(_owners[tokenId] == from, "Incorrect owner");
        require(to != address(0), "Transfer to zero");

        // Clear approvals
        _tokenApprovals[tokenId] = address(0);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeMint(address to, string memory uri) external onlyOwner returns (uint256) {
        require(to != address(0), "Mint to zero");
        uint256 tokenId = _nextTokenId++;
        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;
        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    // Simple burn
    function burn(uint256 tokenId) external {
        address tokenOwner = _owners[tokenId];
        require(isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        _balances[tokenOwner] -= 1;
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(tokenOwner, address(0), tokenId);
    }
}
