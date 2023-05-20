// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract title_deed {
    mapping(address => uint256) house_balance;
    mapping(uint256 => address) house_owners;
    mapping(uint256 => string) house_URI;
    mapping(uint256 => bool) is_sell;
    mapping(uint256 => uint256) sell_price;
    mapping(address => uint256) money_balance;

    string public name;
    string public symbol;
    uint256 public money_total;
    uint8 public decimals = 0;
    uint256[] tokens;
    address owner;

    event House_Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Money_Transfer(address indexed from, address indexed to, uint256 value);
    modifier isOwner() {
        require(owner == msg.sender, "ERROR: only publisher can access this function");
        _;
    }
    modifier zeroAddr(address account) {
        require(account != address(0), "ERROR: access address 0");
        _;
    }
    modifier validId(uint256 token_id) {
        require(house_owners[token_id] != address(0), "ERROR: invalid token id");
        _;
    }

    constructor(string memory name_, string memory symbol_, uint256 init_money) {
        owner = msg.sender;
        name = name_;
        symbol = symbol_;
        money_total = init_money;
        money_balance[msg.sender] = init_money;
    }

    //money
    function moneyBalanceOf(address account) public view zeroAddr(account) returns(uint256) {
        return money_balance[account];
    }

    function money_transfer(address to, uint256 amount) public zeroAddr(to) returns(bool) {
        uint256 myBalance = money_balance[msg.sender];
        require(myBalance >= amount, "No money to transfer");
        money_balance[msg.sender] -= amount;
        money_balance[to] += amount;
        emit Money_Transfer(msg.sender, to, amount);
        return true;
    }

    function mint_money(address to, uint256 amount) public isOwner zeroAddr(to) {
        money_total += amount;
        money_balance[to] += amount;
        emit Money_Transfer(address(0), to, amount);
    }

    function burn_money(address from, uint256 amount) public isOwner zeroAddr(from){
        uint256 num_money = money_balance[from];
        require(num_money >= amount, "ERROR: burn amount exceeds balance");
        money_balance[from] = num_money - amount;
        money_total -= amount;
        emit Money_Transfer(from, address(0), amount);
    }

    // house
    function houseBalanceOf(address account) public view zeroAddr(account) returns(uint256) {
        return house_balance[account];
    }

    function all_house() public view returns(uint256[] memory) {
        return tokens;
    }

    function house_owner(uint256 tokenId) public view validId(tokenId)returns (address) {
        return house_owners[tokenId];
    }

    function search_sell(uint256 tokenId) public view returns(bool) {
        return is_sell[tokenId];
    }

    function search_price(uint256 tokenId) public view returns(uint256) {
        return sell_price[tokenId];
    }

    function house_transfer(address to, uint256 tokenId) public {
        address owner_of = house_owners[tokenId];
        require(owner_of == msg.sender, "ERROR: You are not house owner");
        house_owners[tokenId] = to;
        house_balance[msg.sender] -= 1;
        house_balance[to] += 1;
        emit House_Transfer(msg.sender, to, tokenId);
    }

    function mint_house(address to, uint256 tokenId, uint256 price) public zeroAddr(to) {
        address owner_of = house_owners[tokenId];
        require(owner_of == address(0), "ERROR: tokenId existed");
        house_owners[tokenId] = to;
        sell_price[tokenId] = price;
        is_sell[tokenId] = false;
        tokens.push(tokenId);
        house_balance[to] += 1;
        emit House_Transfer(address(0), to, tokenId);
    }

    function burn_house(uint256 tokenId) public {
        address owner_of = house_owners[tokenId];
        require(owner_of == msg.sender, "ERROR: You are not house owner");
        delete house_owners[tokenId];
        delete sell_price[tokenId];
        delete is_sell[tokenId];
        for (uint i=0; i<tokens.length; i+=1) {
            if(tokens[i]==tokenId) {
                tokens[i]=tokens[tokens.length-1];
                tokens.pop();
            }
        }
        house_balance[msg.sender] -= 1;
        emit House_Transfer(owner_of, address(0), tokenId);
    }

    function my_house() public view returns (uint256[] memory) {
        uint256 num = house_balance[msg.sender];
        uint256[] memory result = new uint[](num);
        uint256 count=0;
        for (uint256 i=0; count<num; i++) {
            if (msg.sender == house_owners[tokens[i]]) {
                result[count] = tokens[i];
                count += 1;
            }
        }
        return result;
    }

    function set_house_price(uint256 tokenId, uint256 price) public {
        address owner_of = house_owners[tokenId];
        require(owner_of == msg.sender, "ERROR: You are not house owner");
        sell_price[tokenId] = price;
    }

    function set_sell(uint256 tokenId, bool state) public {
        address owner_of = house_owners[tokenId];
        require(owner_of == msg.sender, "ERROR: You are not house owner");
        is_sell[tokenId] = state;
    }

    function buy_house(uint256 tokenId) public validId(tokenId) {
        require(is_sell[tokenId] == true, "ERROR: The hosue is not for sell");
        require(money_balance[msg.sender] >= sell_price[tokenId], "ERROR: You don't have enough money");
        address owner_of = house_owners[tokenId];
        house_balance[msg.sender] += 1;
        house_balance[owner_of] -= 1;
        is_sell[tokenId] = false;
        house_owners[tokenId] = msg.sender;
        money_balance[msg.sender] -= sell_price[tokenId];
        money_balance[owner_of] += sell_price[tokenId];
        emit House_Transfer(owner_of, msg.sender, tokenId);
        emit Money_Transfer(msg.sender, owner_of, sell_price[tokenId]);
    }

    function tokenURI(uint256 tokenId) public view validId(tokenId) returns (string memory) {
        return house_URI[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory URI) public validId(tokenId) {
        house_URI[tokenId] = URI;
    }
}