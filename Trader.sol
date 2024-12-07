// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AITradingAgent is Ownable {
    using Counters for Counters.Counter;

    // Constructor
    constructor() Ownable(msg.sender) {}

    // Events
    event TradeExecuted(address indexed user, string tradeId, string token, uint256 amount, uint256 price);
    event AttestationRecorded(address indexed user, string tradeId, string details);

    // Structures
    struct Trade {
        address user;
        string tradeId;
        string token;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
    }

    Counters.Counter private tradeCounter;

    // Mappings
    mapping(string => Trade) public trades; // Mapping tradeId to Trade details
    mapping(address => string[]) public userTrades; // Mapping user address to trade IDs

    // Trade Execution
    function executeTrade(
        address user,
        string memory token,
        uint256 amount,
        uint256 price,
        string memory tradeId
    ) external onlyOwner {
        require(user != address(0), "Invalid user address");
        require(amount > 0, "Invalid trade amount");

        // Record the trade
        trades[tradeId] = Trade({
            user: user,
            tradeId: tradeId,
            token: token,
            amount: amount,
            price: price,
            timestamp: block.timestamp
        });

        userTrades[user].push(tradeId);

        emit TradeExecuted(user, tradeId, token, amount, price);
    }

    // Attestation Recording
    function recordAttestation(
        address user,
        string memory tradeId,
        string memory details
    ) external onlyOwner {
        require(bytes(tradeId).length > 0, "Invalid trade ID");
        require(bytes(details).length > 0, "Details cannot be empty");
        require(trades[tradeId].user == user, "Trade does not match user");

        emit AttestationRecorded(user, tradeId, details);
    }

    // Get Trades by User
    function getUserTrades(address user) external view returns (string[] memory) {
        return userTrades[user];
    }

    // Get Trade Details
    function getTradeDetails(string memory tradeId) external view returns (Trade memory) {
        return trades[tradeId];
    }

    // Emergency withdrawal function (in case of stuck funds)
    function withdrawToken(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }
}
